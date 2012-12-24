use strict;
use warnings;
use Test::More;

plan skip_all => 'todo';

# These dists have a wrong provides list for whatever reasons;
# (found after processing the current minicpan)
my @files_with_wrong_provides = (
  'T/TU/TURNSTEP/Math-GMP-2.06.tar.gz',
  'M/MO/MONS/uni-perl-0.91.tar.gz',
  'M/MU/MUGENKEN/Helper-Commit-0.000004.tar.gz',
  'M/MU/MUGENKEN/Helper-Commit-0.000003.tar.gz',
  'M/MU/MUGENKEN/Unicorn-Manager-0.006008.tar.gz',
  'G/GR/GROMMIER/Text-Editor-Easy-0.49.tar.gz',
  'S/SH/SHOOP/Timestamp-Simple-1.01.tar.gz',
  'L/LB/LBROCARD/Devel-ebug-HTTP-0.32.tar.gz',
  'B/BO/BOBTFISH/Catalyst-Plugin-Cache-Memcached-0.8.tar.gz',
  'M/MB/MBUSIK/XML-Traverse-ParseTree-0.03.tar.gz',
  'A/AS/ASLETT/Net-Rsh-0.05.tar.gz',
);

done_testing;
