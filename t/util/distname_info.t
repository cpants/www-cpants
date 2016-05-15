use WWW::CPANTS;
use WWW::CPANTS::Test;
use WWW::CPANTS::Util::DistnameInfo;

my $info = distinfo("/home/ishigaki/backpan/authors/id/I/IS/ISHIGAKI/Path-Extended-0.19.tar.gz");

is $info->{path} => "I/IS/ISHIGAKI/Path-Extended-0.19.tar.gz";

note explain $info;

done_testing;
