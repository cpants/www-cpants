package WWW::CPANTS::DB::DistTools;

use strict;
use warnings;
use base 'WWW::CPANTS::DB::Base';
use Time::Piece;
use Scope::OnExit;

sub _columns {(
  [analysis_id => 'integer not null', {bulk_key => 1}],
  [author => 'text'],
  [released => 'integer'],
  [has_makefile_pl => 'integer'],
  [has_build_pl => 'integer'],
  [has_module_install => 'integer'],
  [has_dist_ini => 'integer'],
  [has_cpanfile => 'integer'],
  [has_meta_yml => 'integer'],
  [has_meta_json => 'integer'],
  [has_mymeta_yml => 'integer'],
  [has_mymeta_json => 'integer'],
  [generated_by => 'text'],
)}

sub _indices {(
  unique => ['analysis_id'],
)}

sub fetch_stats {
  my $self = shift;

  my $year = Time::Piece->new->year;

  $self->attach('Kwalitee');
  on_scope_exit { $self->detach('Kwalitee') };

  my %map = (
    eumm    => 'ExtUtils::MakeMaker',
    mb      => 'Module::Build',
    mi      => 'Module::Install',
    dzil    => 'Dist::Zilla',
    milla   => 'Milla',
    minilla => 'Minilla',
    others  => 'others',
    unknown => 'unknown',
  );

  $self->fetchall(qq{
    select
      strftime('%Y', k.released, 'unixepoch') + 0 as year,
  } . join('', map {qq{
      sum(case when generated_by = '$map{$_}' then 1 else 0 end) as backpan_${_},
      sum(case when k.is_cpan > 0 and generated_by = '$map{$_}' then 1 else 0 end) as cpan_${_},
      sum(case when k.is_latest > 0 and generated_by = '$map{$_}' then 1 else 0 end) as latest_${_},
  }} keys %map) . qq{
      sum(case when k.is_latest > 0 then 1 else 0 end) as latest_total,
      sum(case when k.is_cpan > 0 then 1 else 0 end) as cpan_total,
      sum(1) as backpan_total
    from kwalitee as k, dist_tools as d
    where d.analysis_id = k.analysis_id and year between ? + 0 and ? + 0
    group by year order by year asc
  }, $year - 9, $year);
}

1;

__END__

=head1 NAME

WWW::CPANTS::DB::DistTools

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 METHODS

=head2 fetch_stats

=head1 AUTHOR

Kenichi Ishigaki, E<lt>ishigaki@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2013 by Kenichi Ishigaki.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
