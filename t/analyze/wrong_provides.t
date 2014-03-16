use strict;
use warnings;
use Test::More;

plan skip_all => 'todo';

# These dists have a wrong provides list for whatever reasons;
# (found after processing the current minicpan)
my @files_with_wrong_provides = (
  'TURNSTEP/Math-GMP-2.06.tar.gz',
  'MONS/uni-perl-0.91.tar.gz',
  'MUGENKEN/Helper-Commit-0.000004.tar.gz',
  'MUGENKEN/Helper-Commit-0.000003.tar.gz',
  'MUGENKEN/Unicorn-Manager-0.006008.tar.gz',
  'GROMMIER/Text-Editor-Easy-0.49.tar.gz',
  'SHOOP/Timestamp-Simple-1.01.tar.gz',
  'LBROCARD/Devel-ebug-HTTP-0.32.tar.gz',
  'BOBTFISH/Catalyst-Plugin-Cache-Memcached-0.8.tar.gz',
  'MBUSIK/XML-Traverse-ParseTree-0.03.tar.gz',
  'ASLETT/Net-Rsh-0.05.tar.gz',
);

done_testing;
