use strict;
use warnings;
use WWW::CPANTS::Test;

plan skip_all => "set WWW_CPANTS_API_TEST to test this" unless $ENV{WWW_CPANTS_API_TEST};

requires_network("api.cpanauthors.org");

subtest '/kwalitee/:id' => sub {
  my $data = get_cpants_api_ok(api => "/kwalitee/ISHIGAKI");
  ok ref $data eq ref {};

  ok $data->{info};
  ok $data->{info}{Average_Kwalitee} > 100;
  ok $data->{info}{CPANTS_Game_Kwalitee} > 90;
  is $data->{info}{Email} => 'ishigaki@cpan.org';
  is $data->{info}{Liga} => '5 or more';
  ok $data->{info}{Rank} > 0;

  ok $data->{distributions};
  ok $data->{distributions}{"Acme-CPANAuthors"};
  ok $data->{distributions}{"Acme-CPANAuthors"}{details};
  ok $data->{distributions}{"Acme-CPANAuthors"}{kwalitee};
  is $data->{distributions}{"Acme-CPANAuthors"}{details}{use_strict} => 'ok';
  # note explain $data;
} if 0;

subtest '/uploads/dist?d=' => sub {
  my $data = get_cpants_api_ok(api => "/uploads/dist", {d => 'Acme-CPANAuthors'});
  ok ref $data eq ref [];
  my $dist = $data->[0];
  is $dist->{author} => 'ISHIGAKI';
  is $dist->{dist} => 'Acme-CPANAuthors';
  like $dist->{filename} => qr/^Acme-CPANAuthors-\d+\.\d+\.tar\.gz$/;
  like $dist->{released} => qr/^[0-9]+$/;
  is $dist->{type} => 'cpan';
  like $dist->{version} => qr/^\d+\.\d+$/;
  # note explain $data;
} if 0;

done_testing;
