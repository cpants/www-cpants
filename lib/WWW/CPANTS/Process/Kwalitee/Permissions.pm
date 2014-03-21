package WWW::CPANTS::Process::Kwalitee::Permissions;

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

  $self->log(debug => "updating package authorization");

  my $kwalitee_db = db('Kwalitee');
  my $errors_db = db('Errors');
  my $perms_db = db_r('Permissions');
  my $provides_db = db('Provides');

  $errors_db->mark(qw/no_unauthorized_packages/);
  $provides_db->mark;
  my %map;
  while(my $row = $perms_db->iterate) {
    my @packages = split ',', $row->{packages};
    $provides_db->authorize($row->{author}, \@packages);
    $map{$_} = 1 for @packages;
  }
  $provides_db->unmark;

  {
    my @unauthorized_dists;
    for ($provides_db->unauthorized_dists) {
      # ignore packages nobody claims in 06perms
      my @unauthorized_packages = grep { $map{$_} }
                                  split /,/, $_->{packages};
      next unless @unauthorized_packages;

      $errors_db->bulk_insert({
        analysis_id => $_->{analysis_id},
        distv => $_->{distv},
        category => 'no_unauthorized_packages',
        error => join(',', @unauthorized_packages),
      });
      push @unauthorized_dists, $_->{analysis_id};
    }
    $errors_db->finalize_bulk_insert;
    $kwalitee_db->mark_unauthorized(\@unauthorized_dists);
  }

  $errors_db->unmark(qw/no_unauthorized_packages/);
}

1;

__END__

=head1 NAME

WWW::CPANTS::Process::Kwalitee::Permissions

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 METHODS

=head2 new
=head2 update

=head1 AUTHOR

Kenichi Ishigaki, E<lt>ishigaki@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2013 by Kenichi Ishigaki.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
