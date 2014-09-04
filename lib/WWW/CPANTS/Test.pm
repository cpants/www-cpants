package WWW::CPANTS::Test;

use strict;
use warnings;
use Test::More;
use Test::Differences;
use WWW::CPANTS::AppRoot;
use WWW::CPANTS::DB;
use WWW::CPANTS::Log;
use WWW::CPANTS::Extlib;
use Exporter::Lite;
use WorePAN;
use Carp;
use IO::Capture::Stderr;
use Time::Piece;
use JSON::XS;

local $ENV{WWW_CPANTS_SLOW_QUERY} = 1;

$Carp::Verbose = $ENV{TEST_VERBOSE};
$Carp::CarpLevel = 1;

$SIG{__DIE__} = sub { croak(@_) };

our @EXPORT = (
  @Test::More::EXPORT,
  @Test::Differences::EXPORT,
  qw/setup_mirror no_scan_table epoch test_network
  test_kwalitee test_context_stash/,
);

my $worepan;
my $pid;

sub setup_mirror {
  my @files = @_;

  my %opts;
  if (ref $files[-1] eq ref {}) {
    %opts = %{pop @files};
  }

  unless (@files) {
    @files = qw{
      I/IS/ISHIGAKI/Path-Extended-0.19.tar.gz
    };
  }

  my $mirror = dir('mirror')->mkdir;
  my $local_mirror = appdir('tmp/test_mirror')->mkdir;
  $worepan = WorePAN->new(
    root => $mirror->path,
    local_mirror => $local_mirror->path,
    files => \@files,
    no_network => 0,
    no_indices => defined $opts{no_indices} ? $opts{no_indices} : 1,
    use_backpan => 1,
  );
  $mirror->recurse(callback => sub {
    my $e = shift;
    return unless -f $e->path;
    my $path = $e->relative($mirror);
    my $local_copy = $local_mirror->file($path);
    $e->copy_to($local_copy) unless $local_copy->exists;
  });
  $pid = $$;
  $worepan;
}

sub no_scan_table (&;$) {
  my ($test, $skip) = @_;
  my ($package, $file, $line) = caller;

  my $capture = IO::Capture::Stderr->new;
  $capture->start;
  eval { $test->() };
  my $error = $@ ? $@ : '';
  $capture->stop;
  fail $error if $error;
  my @captured = $capture->read;
  my @scan_table = grep { /SCAN TABLE/ && !/USING (?:COVERING )?INDEX/ } @captured;
  SKIP: {
    skip $skip, 1 if $skip;
    ok !@scan_table, "no scan table: line $line";
  }
  note join '', @captured;
}

sub epoch { Time::Piece->strptime(shift, '%Y-%m-%d')->epoch }

sub test_network {
  my $host = shift;
  require Socket;
  eval { Socket::inet_aton($host) }
    or plan skip_all => "This test requires network to $host";
}

sub test_kwalitee {
  my ($name, @tests) = @_;

  require WWW::CPANTS::Analyze;
  my $mirror = setup_mirror(map {$_->[0]} @tests);

  for my $test (@tests) {
    my $tarball = $mirror->file($test->[0]);
    my $analyzer = WWW::CPANTS::Analyze->new;
    my $context = $analyzer->analyze(dist => $tarball);

    my $metric = $analyzer->metric($name);
    my $result = $metric->{code}->($context->stash, $metric);
    is $result => $test->[1], $test->[0] . " $name: $result";

    if (!$result) {
      my $details = $metric->{details}->($context->stash) || '';
      ok $details, ref $details ? encode_json($details) : $details;
    }
    if ($test->[2]) {
      note explain $context->stash;
    }
  }
}

sub test_context_stash {
  my ($tests, $code) = @_;

  require WWW::CPANTS::Analyze;
  my $mirror = setup_mirror(@$tests);

  for my $test (@$tests) {
    my $tarball = $mirror->file($test);
    my $analyzer = WWW::CPANTS::Analyze->new;
    my $context = $analyzer->analyze(dist => $tarball);
    ok $context;
    $code->(decode_json($context->dump_stash));
  }
}

END {
  if (Test::More->builder->is_passing) {
    if ($pid && $pid == $$) {
      $worepan->root->remove if $worepan;
    }
  }
  WWW::CPANTS::Log->logger(0);
}

1;

__END__

=head1 NAME

WWW::CPANTS::Test

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 METHODS

=head2 setup_mirror
=head2 no_scan_table
=head2 epoch
=head2 test_network
=head2 test_kwalitee
=head2 test_context_stash

=head1 AUTHOR

Kenichi Ishigaki, E<lt>ishigaki@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 by Kenichi Ishigaki.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
