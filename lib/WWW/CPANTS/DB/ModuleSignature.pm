package WWW::CPANTS::DB::ModuleSignature;

use strict;
use warnings;
use base 'WWW::CPANTS::DB::Base';
use Scope::OnExit;

my %RESULT = (
  '0E0' => 'CANNOT_VERIFY',
  '0'   => 'SIGNATURE_OK',
  '-1'  => 'SIGNATURE_MISSING',
  '-2'  => 'SIGNATURE_MALFORMED',
  '-3'  => 'SIGNATURE_BAD',
  '-4'  => 'SIGNATURE_MISMATCH',
  '-5'  => 'MANIFEST_MISMATCH',
  '-6'  => 'CIPHER_UNKNOWN',
);

sub _columns {(
  [analysis_id => 'integer not null', {bulk_key => 1}],
  [result_cd => 'text'],
  [released => 'integer'],
)}

sub _indices {(
  unique => ['analysis_id'],
  ['result_cd'],
)}

sub fetch_result_stats {
  my $self = shift;

  $self->attach('Kwalitee');
  on_scope_exit { $self->detach('Kwalitee') };

  my $stats = $self->fetchall(qq{
    select
      result_cd,
      sum(case when k.is_latest > 0 then 1 else 0 end) as latest,
      sum(case when k.is_cpan > 0 then 1 else 0 end) as cpan,
      sum(1) as backpan,
      group_concat(distinct(case when k.is_latest > 0 then k.author else NULL end)) as authors
    from module_signature as m, kwalitee as k
    where m.analysis_id = k.analysis_id
    group by result_cd order by result_cd desc
  });

  for (@$stats) {
    $_->{result} = defined $_->{result_cd}
      ? $RESULT{$_->{result_cd}} || 'UNKNOWN: '.$_->{result_cd}
      : 'SKIPPED';
  }

  $stats;
}

sub fetch_usage_stats {
  my $self = shift;

  my $year = Time::Piece->new->year;

  $self->attach('Kwalitee');
  on_scope_exit { $self->detach('Kwalitee') };

  $self->fetchall(qq{
    select
      strftime('%Y', m.released, 'unixepoch') + 0 as year,
      sum(case when result_cd = '0' then 1 else 0 end) as backpan_ok,
      sum(case when result_cd = '-1' then 1 else 0 end) as backpan_missing,
      sum(case when result_cd + 0 < -1 then 1 else 0 end) as backpan_errors,
      sum(case when k.is_cpan > 0 and result_cd = '0' then 1 else 0 end) as cpan_ok,
      sum(case when k.is_cpan > 0 and result_cd = '-1' then 1 else 0 end) as cpan_missing,
      sum(case when k.is_cpan > 0 and result_cd + 0 < -1 then 1 else 0 end) as cpan_errors,
      sum(case when k.is_latest > 0 and result_cd = '0' then 1 else 0 end) as latest_ok,
      sum(case when k.is_latest > 0 and result_cd = '-1' then 1 else 0 end) as latest_missing,
      sum(case when k.is_latest > 0 and result_cd + 0 < -1 then 1 else 0 end) as latest_errors,
      sum(case when k.is_latest > 0 then 1 else 0 end) as latest_total,
      sum(case when k.is_cpan > 0 then 1 else 0 end) as cpan_total,
      sum(1) as backpan_total,
      group_concat(distinct(case when result_cd != '-1' and k.is_latest > 0 then k.author else NULL end)) as latest_authors,
      group_concat(distinct(case when result_cd != '-1' and k.is_cpan > 0 then k.author else NULL end)) as cpan_authors,
      group_concat(distinct(case when result_cd != '-1' then k.author else NULL end)) as backpan_authors
    from module_signature as m, kwalitee as k
    where m.analysis_id = k.analysis_id and year between ? + 0 and ? + 0
    group by year order by year asc
  }, $year - 9, $year);
}

1;

__END__

=head1 NAME

WWW::CPANTS::DB::ModuleSignature

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 METHODS

=head2 fetch_result_stats
=head2 fetch_usage_stats

=head1 AUTHOR

Kenichi Ishigaki, E<lt>ishigaki@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 by Kenichi Ishigaki.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
