use strict;
use warnings;
use WWW::CPANTS::Test;
use WWW::CPANTS::Analyze;

my @paths = qw(
  J/JC/JCAMACHO/Catalyst-Controller-FormBuilder-0.01_01.tar.gz
);

my $mirror = setup_mirror(@paths);

# This test should pass with Archive::Any::Lite >= 0.04

my $analyzer = WWW::CPANTS::Analyze->new;
for my $path (@paths) {
  my $context;
  eval {
    local $SIG{ALRM} = sub { fail "extract_never_ends test fails"; die "extract_never_ends test fails"; };
    alarm 5;
    $context = $analyzer->analyze(dist => $mirror->file($path));
    alarm 0;
  };
  ok !$@, "no obvious errors";
  ok $context, "context exists";
  my $error = $context->stash->{error}{extract} || '';
  unlike $error => qr/extract_never_ends test fails/, "proper error is recorded";
}

done_testing;
