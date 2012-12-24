package WWW::CPANTS::DB::DistSize;

use strict;
use warnings;
use base 'WWW::CPANTS::DB::Base';

sub _columns {(
  [analysis_id => 'integer primary key not null', {bulk_key => 1}],
  [size_packed => 'integer'],
  [size_unpacked => 'integer'],
  [files => 'integer'],
)}

sub _indices {(
  ['size_packed'],
  ['size_unpacked'],
  ['files'],
)}

sub fetch_packed_size_stats {
  my $self = shift;
  $self->attach('Kwalitee');
  my $kb = 1000;  # or better use Kibibyte?
  my $rows = $self->fetchall(qq{
    select cat, count(cat) as count, min(size_packed) as sort from (
      select (
        case
    } . (
      join "\n", map {
        sprintf
          q{when size_packed > %d then "> %d KB"}, $_ * $kb, $_;
      }
      (5000, 1000, 500, 200, 100, 50, 40, 30, 20, 10, 7, 5, 3, 2, 1)
    ) . qq{
          else "less than 1 KB"
        end
      ) as cat, size_packed from dist_size, kwalitee.kwalitee as k
      where dist_size.analysis_id = k.analysis_id and k.is_latest > 0
    ) as cat group by cat order by sort desc
  });
  $self->detach('Kwalitee');
  return $rows;
}

sub fetch_unpacked_size_stats {
  my $self = shift;
  $self->attach('Kwalitee');
  my $kb = 1000;  # or better use Kibibyte?
  my $rows = $self->fetchall(qq{
    select cat, count(cat) as count, min(size_unpacked) as sort from (
      select (
        case
    } . (
      join "\n", map {
        sprintf
          q{when size_unpacked > %d then "> %d KB"}, $_ * $kb, $_;
      }
      (5000, 1000, 500, 200, 100, 50, 40, 30, 20, 10, 7, 5, 3, 2, 1)
    ) . qq{
          else "less than 1 KB"
        end
      ) as cat, size_unpacked from dist_size, kwalitee.kwalitee as k
      where dist_size.analysis_id = k.analysis_id and k.is_latest > 0
    ) as cat group by cat order by sort desc
  });
  $self->detach('Kwalitee');
  return $rows;
}

sub fetch_largest_dists {
  my $self = shift;
  $self->attach('Kwalitee');
  my $rows = $self->fetchall(q{
    select
      k.distv as distv,
      k.author as author,
      d.size_packed as packed,
      d.size_unpacked as unpacked
    from (
      select analysis_id, size_packed, size_unpacked from dist_size
      order by size_unpacked desc
    ) as d, kwalitee.kwalitee as k
    where d.analysis_id = k.analysis_id and k.is_latest > 0
    limit 100
  });
  $self->detach('Kwalitee');
  return $rows;
}

1;

__END__

=head1 NAME

WWW::CPANTS::DB::DistSize

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 METHODS

=head2 fetch_largest_dists
=head2 fetch_packed_size_stats
=head2 fetch_unpacked_size_stats

=head1 AUTHOR

Kenichi Ishigaki, E<lt>ishigaki@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 by Kenichi Ishigaki.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
