package WWW::CPANTS::DB::Provides;

use strict;
use warnings;
use base 'WWW::CPANTS::DB::Base';

sub _columns {(
  [analysis_id => 'integer not null', {bulk_key => 1}],
  [author => 'text'],
  [distv => 'text'],
  [released => 'integer'],
  [package => 'text', {bulk_key => 1}],
  [version => 'text'],
  [version_num => 'float'],
  [is_primary => 'integer'],
  [authorized => 'integer default 0', {no_bulk => 1}],
)}

sub _indices {(
  unique => [qw/package analysis_id/],
)}

sub mark {
  my $self = shift;
  $self->do("update provides set authorized = (case when authorized > 0 then 2 else 0 end)");
  $self->{marked} = 1;
}

sub unmark {
  my $self = shift;
  $self->do("update provides set authorized = 0 where authorized = 2");
  delete $self->{marked};
}

sub authorize {
  my ($self, $author, $packages) = @_;
  my $params = $self->_in_params($packages);
  if ($author) {
    $self->do("update provides set authorized = 1 where author = ? and package in ($params)", $author);
  } else {
    $self->do("update provides set authorized = 1 where package in ($params)");
  }
}

sub unauthorized_dists {
  my $self = shift;
  my $table = $self->table;
  $self->fetchall("select analysis_id, distv, group_concat(package) as packages from provides where is_primary = 1 and authorized = 0 group by distv");
}

1;

__END__

=head1 NAME

WWW::CPANTS::DB::Provides

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 METHODS

=head2 new
=head2 authorize
=head2 mark
=head2 unmark
=head2 unauthorized_dists

=head1 AUTHOR

Kenichi Ishigaki, E<lt>ishigaki@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2013 by Kenichi Ishigaki.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
