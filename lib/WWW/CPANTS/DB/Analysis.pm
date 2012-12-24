package WWW::CPANTS::DB::Analysis;

use strict;
use warnings;
use base 'WWW::CPANTS::DB::Base';

sub _columns {(
  [id => 'integer primary key autoincrement not null', {no_bulk => 1}],
  [path => 'text not null unique', {bulk_key => 1}],
  [distv => 'text'],
  [author => 'text'],
  [json => 'text'],
  [duration => 'integer'],
)}

# - Process::Analysis -

sub has_analyzed {
  my $self = shift;
  $self->fetch_1('select id from analysis where path = ?', shift);
}

sub insert_or_update {
  my ($self, $bind) = @_;

  unless ($self->{_bulk_insert_sths}) {
    $self->_prepare_bulk_insert;
  }

  my $id;
  my $dbh = $self->dbh;
  $dbh->sqlite_update_hook(sub {(undef, undef, undef, $id) = @_ });
  my @params = @$bind{qw/distv author json duration path/};
  $dbh->begin_work;
  eval {
    my $ret = $self->{_bulk_insert_sths}[0]->execute(@params);
    if (!$ret or $ret eq '0E0') {
      $ret = $self->{_bulk_insert_sths}[1]->execute(@params);
    }
  };
  if ($@) {
    warn $@;
    $dbh->rollback;
    return;
  }
  $dbh->commit;
  return $id ? $id : undef;
}

# - Page::Dist::Metadata -

sub fetch_json_by_id {
  my ($self, $id) = @_;
  $self->fetch_1('select json from analysis where id = ?', $id);
}

# - currently for testing only -

sub update_json_by_id {
  my ($self, $id, $json) = @_;
  $self->do('update analysis set json = ? where id = ?', $json, $id);
}

sub fetch_path_by_distv {
  my ($self, $distv) = @_;
  $self->fetch_1('select path from analysis where distv = ?', $distv);
}

1;

__END__

=head1 NAME

WWW::CPANTS::DB::Analysis

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 METHODS

=head2 fetch_json_by_id
=head2 fetch_path_by_distv
=head2 has_analyzed
=head2 insert_or_update
=head2 update_json_by_id

=head1 AUTHOR

Kenichi Ishigaki, E<lt>ishigaki@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 by Kenichi Ishigaki.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
