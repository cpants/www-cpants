package WWW::CPANTS::DB::XS;

use strict;
use warnings;
use base 'WWW::CPANTS::DB::Base';
use Time::Piece;
use Scope::OnExit;

sub _columns {(
  [analysis_id => 'integer not null', {bulk_key => 1}],
  [author => 'text'],
  [released => 'integer'],
  [has_xs => 'integer'],
  [has_c => 'integer'],
  [has_cpp => 'integer'],
  [has_ppport_h => 'integer'],
)}

sub _indices {(
  unique => ['analysis_id'],
)}

sub fetch_stats {
  my $self = shift;

  my $year = Time::Piece->new->year;

  $self->attach('Kwalitee');
  on_scope_exit { $self->detach('Kwalitee') };

  $self->fetchall(qq{
    select
      strftime('%Y', k.released, 'unixepoch') + 0 as year,
      sum(case when has_xs > 0 then 1 else 0 end ) as backpan_xs,
      sum(case when has_xs > 0 and k.is_cpan > 0 then 1 else 0 end) as cpan_xs,
      sum(case when has_xs > 0 and k.is_latest > 0 then 1 else 0 end) as latest_xs,
      sum(case when has_c > 0 then 1 else 0 end ) as backpan_c,
      sum(case when has_c > 0 and k.is_cpan > 0 then 1 else 0 end) as cpan_c,
      sum(case when has_c > 0 and k.is_latest > 0 then 1 else 0 end) as latest_c,
      sum(case when has_cpp > 0 then 1 else 0 end ) as backpan_cpp,
      sum(case when has_cpp > 0 and k.is_cpan > 0 then 1 else 0 end) as cpan_cpp,
      sum(case when has_cpp > 0 and k.is_latest > 0 then 1 else 0 end) as latest_cpp,
      sum(case when has_ppport_h > 0 then 1 else 0 end ) as backpan_ppport_h,
      sum(case when has_ppport_h > 0 and k.is_cpan > 0 then 1 else 0 end) as cpan_ppport_h,
      sum(case when has_ppport_h > 0 and k.is_latest > 0 then 1 else 0 end) as latest_ppport_h,
      sum(case when k.is_latest > 0 then 1 else 0 end) as latest_total,
      sum(case when k.is_cpan > 0 then 1 else 0 end) as cpan_total,
      sum(1) as backpan_total
    from kwalitee as k left join xs as x on x.analysis_id = k.analysis_id
    where year between ? + 0 and ? + 0
    group by year order by year asc
  }, $year - 9, $year);
}

1;

__END__

=head1 NAME

WWW::CPANTS::DB::XS

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
