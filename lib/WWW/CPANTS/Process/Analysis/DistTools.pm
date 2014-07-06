package WWW::CPANTS::Process::Analysis::DistTools;

use strict;
use warnings;
use WWW::CPANTS::DB;

sub new {
  bless {
    db => db('DistTools')->setup,
  }, shift;
}

sub update {
  my ($self, $data) = @_;

  # ignore Module::Build::Tiny as it doesn't generate META files
  my @rules = (
    ['ExtUtils::MakeMaker' => qr/ExtUtils::MakeMaker|EUMM/],
    ['Module::Build'],
    ['Module::Install'],
    ['Milla'],  # should be put before Dist::Zilla
    ['Minilla'],
    ['Dist::Zilla'],
  );

  my $meta_yml = $data->{meta_yml} || {};
  my $generated_by = $meta_yml->{generated_by} || '';
  my $generator = $generated_by ? 'others' : 'unknown';
  for (@rules) {
    my $rule = $_->[1] || $_->[0];
    if ($generated_by =~ /$rule/) {
      $generator = $_->[0];
      last;
    }
  }

  $self->{db}->bulk_insert({
    analysis_id => $data->{id},
    author => $data->{author},
    released => $data->{released_epoch},
    has_makefile_pl => $data->{file_makefile_pl} ? 1 : 0,
    has_build_pl => $data->{file_build_pl} ? 1 : 0,
    has_module_install => $data->{module_install}{version} ? 1 : 0,
    has_dist_ini => $data->{files_hash}{"dist.ini"} ? 1 : 0,
    has_cpanfile => $data->{files_hash}{"cpanfile"} ? 1 : 0,
    has_meta_yml => $data->{file_meta_yml} ? 1 : 0,
    has_meta_json => $data->{files_hash}{"META.json"} ? 1 : 0,
    has_mymeta_yml => $data->{files_hash}{"MYMETA.yml"} ? 1 : 0,
    has_mymeta_json => $data->{files_hash}{"MYMETA.json"} ? 1 : 0,
    generated_by => $generator,
  });
}

sub finalize {
  shift->{db}->finalize_bulk_insert;
}

1;

__END__

=head1 NAME

WWW::CPANTS::Process::Analysis::DistTools

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 METHODS

=head2 new
=head2 update
=head2 finalize

=head1 AUTHOR

Kenichi Ishigaki, E<lt>ishigaki@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2013 by Kenichi Ishigaki.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
