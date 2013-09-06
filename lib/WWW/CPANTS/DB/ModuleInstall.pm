package WWW::CPANTS::DB::ModuleInstall;

use strict;
use warnings;
use base 'WWW::CPANTS::DB::Base';
use Scope::OnExit;

sub _columns {(
  [analysis_id => 'integer not null', {bulk_key => 1}],
  [version => 'text'],
  [dist_released => 'integer'],
  [mi_released => 'integer'],
)}

sub _indices {(
  unique => ['analysis_id'],
)}

sub fetch_stats {
  my $self = shift;

  $self->attach('Kwalitee');
  on_scope_exit { $self->detach('Kwalitee') };

  $self->fetchall(qq{
    select
      version,
      count(version) as count,
      sum(case when k.is_latest > 0 then 1 else 0 end) as latest,
      sum(case when k.is_cpan > 0 then 1 else 0 end) as cpan,
      sum(1) as backpan,
      group_concat(distinct(case when k.is_latest > 0 then k.author else NULL end)) as authors
    from module_install as m, kwalitee as k
    where m.analysis_id = k.analysis_id
    group by version order by version desc
  });
}

1;

__END__

=head1 NAME

WWW::CPANTS::DB::ModuleInstall

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 METHODS

=head2 fetch_stats

=head1 AUTHOR

Kenichi Ishigaki, E<lt>ishigaki@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 by Kenichi Ishigaki.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
