use strict;
use warnings;
use WWW::CPANTS::Test;
use WWW::CPANTS::Analyze;

my @tests = (
  ['LAWSONK/Gtk2-Ex-MPlayerEmbed-0.03.tar.gz', 0], # 465
  ['WEBY/Mojolicious-Plugin-Mobi-0.02.tar.gz', 0], # 474
  ['WOLDRICH/Bundle-Woldrich-Term-0.02.tar.gz', 0], # 530
  ['WOLDRICH/App-epic-0.014.tar.gz', 0], # 812
  ['TAG/AnyEvent-Peer39-0.32.tar.gz', 0], # 824
  ['ABCABC/CFTP_01.tar.gz', 0], # 897
  ['SAULIUS/Date-Holidays-LT-0.01.tar.gz', 0], # 1532
  ['RUFF/DJabberd-Authen-Dovecot-0.1.tar.gz', 0], # 2105
  ['UNBIT/Net-uwsgi-1.1.tar.gz', 0], # 2409
  ['GVENKAT/JSON-HPack-0.0.3.tar.gz', 0], # 2475
);

my $mirror = setup_mirror(map {$_->[0]} @tests);

for my $test (@tests) {
  my $tarball = $mirror->file($test->[0]);
  my $analyzer = WWW::CPANTS::Analyze->new;
  my $context = $analyzer->analyze(dist => $tarball);

  my $metric = $analyzer->metric('has_manifest');
  my $result = $metric->{code}->($context->stash);
  is $result => $test->[1], $tarball->basename . " has_manifest: $result";

  if (!$result) {
    my $details = $metric->{details}->($context->stash) || '';
    ok $details, $details;
  }
}

done_testing;
