package WWW::CPANTS::Bin::Task::Grep;

use Mojo::Base 'WWW::CPANTS::Bin::Task', -signatures;
use WWW::CPANTS::Util::JSON;
use Mojo::JSON::Pointer;

our @READ    = qw/Analysis/;
our @OPTIONS = (
    'count',
    'limit=i',
    'show_json|show-json',
);

has 'conditions';

sub run ($self, @args) {
    return unless @args;

    my @conditions;
    while (my ($path, $expr) = splice @args, 0, 2) {
        if ($expr && substr($expr, 0, 1) eq '/') { unshift @args, $expr; $expr = undef }
        push @conditions, [$path, $self->_create_callback($expr)];
    }
    $self->conditions(\@conditions);

    my $limit      = $self->limit;
    my $show_json  = $self->show_json;
    my $count_only = $self->count;

    my $iter  = $self->db->table('Analysis')->iterate;
    my $count = 0;
    while (my $row = $iter->next) {
        next unless defined $row->{json};
        my $data    = decode_json($row->{json});
        my $pointer = Mojo::JSON::Pointer->new($data);

        my $found = $self->_check_condition($pointer) or next;
        $count++;
        next if $count_only;

        say "$row->{path}";
        if ($show_json) {
            say $found;
            say "";
        }
        last if $limit and $limit <= $count;
    }

    say "count: $count" if $count_only;
}

sub _create_callback ($self, $expr) {
    $expr =~ s/\A(["'])(.*)\1\z/$2/ if defined $expr;

    if (!defined $expr or $expr eq '') {
        return sub ($value) { $value ? 1 : 0 };
    }
    if ($expr =~ /\A[<>=]+\s*-?[0-9\.]+\z/) {
        return sub ($value) { eval "$value $expr" ? 1 : 0 };
    }
    return sub ($value) { defined $value && $value =~ /$expr/ };
}

sub _check_condition ($self, $pointer) {
    my @found;
    for my $condition ($self->conditions->@*) {
        my ($path, $sub) = @$condition;
        my $value = $pointer->get($path);
        if (ref $value) {
            $value = encode_json($value);
        }
        $sub->($value) or return;
        push @found, "  $path: $value";
    }
    return join "\n", @found;
}

1;
