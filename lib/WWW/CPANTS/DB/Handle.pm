package WWW::CPANTS::DB::Handle;

use Role::Tiny::With;
use Mojo::Base -base, -signatures;
use DBI;
use DBIx::TransactionManager;
use Scalar::Util qw/blessed/;
use Syntax::Keyword::Try;
use SQL::Maker;

with qw/WWW::CPANTS::Role::Logger/;

has '_dbh';
has 'config';
has 'trace';
has 'pid'         => sub ($self) { $$ };
has 'txn_manager' => \&_build_txn_manager;
has 'sql_maker'   => \&_build_sql_maker;

sub _build_sql_maker ($self) {
    my ($driver_name) = (ref $self || $self) =~ /Handle::(\w+)$/;
    SQL::Maker->load_plugin('InsertMulti');
    SQL::Maker->new(driver => $driver_name);
}

sub _build_txn_manager ($self) {
    my $dbh = $self->dbh or return;
    DBIx::TransactionManager->new($dbh);
}

sub dbh ($self) {
    return $self->_dbh if $self->pid eq $$;
    Carp::cluck("forked handle is used");
}

sub disconnect ($self) {
    return unless $self->pid eq $$ and $self->_dbh;
    $self->_disconnect;
}

sub _disconnect ($self) {
    $_ && $_->finish for values %{ $self->{sth} // {} };
    delete $self->{sth};
    delete $self->{txn_manager};
    $self->{dbh}->disconnect if $self->{dbh};
    delete $self->{dbh};
    return;
}

sub create_table ($self, $table) {
    $self->do($_) for @{ $self->ddl_statements($table) };
}

sub do ($self, $sql, @bind_values) {
    try {
        ($sql, @bind_values) = $self->_tweak_sql($sql, @bind_values);
        my $sth = $self->_prepare($sql);
        $sth->execute(@bind_values);
    } catch {
        my $error = "$sql: $@";
        $self->log(error => $self->_append_caller($error));
    }
}

sub insert ($self, $sql, @bind_values) {
    $self->do($sql, @bind_values);
}

sub update ($self, $sql, @bind_values) {
    $self->do($sql, @bind_values);
}

sub delete ($self, $sql, @bind_values) {
    $self->do($sql, @bind_values);
}

sub iterate ($self, $sql, @bind_values) {
    ($sql, @bind_values) = $self->_tweak_sql($sql, @bind_values);
    my $sth = $self->_prepare($sql);
    $sth->execute(@bind_values);
    WWW::CPANTS::DB::Handle::Iterator->new(sth => $sth);
}

sub _select ($self, $sql, @bind_values) {
    ($sql, @bind_values) = $self->_tweak_sql($sql, @bind_values);
    my $sth = $self->_prepare($sql);
    $sth->execute(@bind_values);
    $sth;
}

sub select ($self, $sql, @bind_values) {
    $self->_select($sql, @bind_values)->fetchrow_hashref;
}

sub select_all ($self, $sql, @bind_values) {
    $self->_select($sql, @bind_values)->fetchall_arrayref({});
}

sub select_col ($self, $sql, @bind_values) {
    my ($col) = $self->_select($sql, @bind_values)->fetchrow_array;
    return $col;
}

sub select_all_col ($self, $sql, @bind_values) {
    my $rows = $self->_select($sql, @bind_values)->fetchall_arrayref([0]) || [];
    return [map { $_->[0] } @$rows];
}

sub exists ($self, $table, $cond) {
    my $table_name  = $table->name;
    my @columns     = sort keys %{ $cond //= {} };
    my $where       = @columns ? "WHERE " . join(' AND ', map { "$_ = ?" } @columns) : "";
    my @bind_values = map { $cond->{$_} } @columns;
    my $sql         = "SELECT 1 FROM $table_name $where LIMIT 1";
    $self->select_col($sql, @bind_values);
}

sub count ($self, $table, $cond) {
    my $table_name  = $table->name;
    my @columns     = sort keys %{ $cond // {} };
    my $where       = @columns ? "WHERE " . join(' AND ', map { "$_ = ?" } @columns) : "";
    my @bind_values = map { $cond->{$_} } @columns;
    my $sql         = "SELECT COUNT(*) FROM $table_name $where";
    $self->select_col($sql, @bind_values);
}

sub prepare ($self, $sql, $opts = undef) {
    ($sql) = $self->_tweak_sql($sql, defined $opts ? $opts : ());
    $self->_prepare($sql);
}

sub _prepare ($self, $sql) {
    return $sql if blessed $sql and $sql->isa('DBI::st');
    $self->dbh->prepare($sql);
}

sub prepare_cached ($self, $sql, $opts = undef) {
    ($sql) = $self->_tweak_sql($sql, defined $opts ? $opts : ());
    return $sql if blessed $sql and $sql->isa('DBI::st');
    $self->dbh->prepare_cached($sql);
}

sub select_max_id ($self, $table) {
    # TODO: check primary key column
    $self->select_col([$table, [\'MAX(id)']]);
}

sub txn ($self, $caller = [caller]) {
    my $txn_manager = $self->txn_manager or return;
    $txn_manager->txn_scope(caller => $caller);
}

sub _append_caller ($self, $sql) {
    return $sql if ref $sql;
    chomp $sql;
    my $i = 1;
    while (my @caller = caller($i++)) {
        my $package = $caller[0];
        next unless $package =~ /^WWW::CPANTS::Bin::Task/;
        # $self->log(debug => "[QUERY] $sql\t[$package $caller[2]]");
        return "$sql /* in $package line $caller[2] */";
    }
    return $sql;
}

sub _tweak_sql ($self, $sql, @bind_values) {
    if (@bind_values) {
        if (ref $bind_values[-1] eq ref {}) {
            my $arg = pop @bind_values;
            if ($arg->{limit}) {
                my $limit_offset = $self->_limit_offset(delete $arg->{limit}, delete $arg->{offset});
                $sql .= " $limit_offset" unless blessed $sql;
            }
        }
        if (ref $bind_values[-1] eq ref []) {
            my $arg = pop @bind_values;
            my ($key, $values) = @$arg;
            $values = [undef] unless @{ $values // [] };
            if (@$values < 500) {
                my $placeholders = substr('?,' x @$values, 0, -1);
                if (!blessed $sql) {
                    $sql =~ s/:$key/$placeholders/ or Carp::confess("no :$key in $sql");
                }
                push @bind_values, @$values;
            } else {
                my $concat = $self->_quote_and_concat($values);
                if (!blessed $sql) {
                    $sql =~ s/:$key/$concat/ or Carp::confess("no :$key in $sql");
                } else {
                    Carp::confess("Can't replace values");
                }
            }
        }
    }

    Carp::confess "\$ found in sql: $sql" if !blessed $sql && $sql =~ /\$/;

    $sql = $self->_append_caller($sql);
    if ($self->trace) {
        $self->log(debug => "[SQL] $sql");
        $self->log(debug => "[BIND] " . $self->_quote_and_concat(\@bind_values)) if $self->trace > 1 and @bind_values;
    }
    return ($sql, @bind_values);
}

sub _quote_and_concat ($self, $params) {
    my $dbh = $self->dbh;
    join ', ', map { $dbh->quote($_) } @$params;
}

sub _limit_offset ($self, $limit = undef, $offset = undef) {
    return '' unless defined $limit;
    if (!defined $limit or $limit =~ /[^0-9]/) {
        $self->log(warn => $self->_append_caller("limit $limit is not number"));
        return '';
    }
    return "LIMIT $limit" unless defined $offset;
    if ($offset =~ /[^0-9]/) {
        $self->log(warn => $self->_append_caller("offset $offset is not number"));
        return '';
    }
    return "LIMIT $limit OFFSET $offset";
}

sub build_update_sql ($self, $table, $columns, $primary_key) {
    return "UPDATE " . $table->name . " SET " . join(",", map { "$_ = ?" } @$columns) . " WHERE $primary_key = ?";
}

sub DESTROY ($self) { $self->disconnect }

package WWW::CPANTS::DB::Handle::Iterator;

use Mojo::Base -base, -signatures;

has 'sth';

sub next ($self) { $self->sth->fetchrow_hashref }

1;
