package WWW::CPANTS::Process::Kwalitee::AuthorStats;

use strict;
use warnings;
use WWW::CPANTS::Log;
use WWW::CPANTS::DB;

sub new {
  my ($class, %args) = @_;
  bless \%args, $class;
}

sub update {
  my $self = shift;

  $self->log(debug => "updating authors stat");

  my $kwalitee_db = db('Kwalitee');
  my $authors_db = db('Authors');

  my $stats = $kwalitee_db->fetch_author_stats;
  $authors_db->update_author_stats($stats);
}

1;

__END__

=head1 NAME

WWW::CPANTS::Process::Kwalitee::AuthorStats

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 METHODS

=head2 new
=head2 update

=head1 AUTHOR

Kenichi Ishigaki, E<lt>ishigaki@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 by Kenichi Ishigaki.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
