#!/usr/bin/env perl
use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/lib";

WWW::CPANTS::Script::FixAnalysis->run_directly;

package WWW::CPANTS::Script::FixAnalysis;
use base 'WWW::CPANTS::Script::Base';
use WWW::CPANTS::Process::Queue;
use WWW::CPANTS::Process::Analysis;
use WWW::CPANTS::AppRoot;
use WWW::CPANTS::Extlib;
use Time::Piece;
use WorePAN;

sub _options {qw/cpan=s no_capture errors/}

sub _run {
  my ($self, @files) = @_;

  if ($self->{errors}) {
    require WWW::CPANTS::DB::Analysis;
    require JSON::XS;
    my $db = WWW::CPANTS::DB::Analysis->new;
    while(my $row = $db->fetch_row) {
      my $data = JSON::XS::decode_json($row->{json});
      if ($data->{error} && $data->{error}{cpants}) {
        push @files, $row->{path};
      }
    }
  }

  my $worepan = WorePAN->new(
    root => appdir('tmp/analyze/'.time)->mkdir->path,
    local_mirror => $self->{cpan},
    files => \@files,
    no_network => 0,
    use_backpan => 1,
  );

  $self->{cpan} = $worepan->root->path;

  $self->{verbose} = 1;
  $self->{logger} = 1;
  $self->{force} = 1;

  WWW::CPANTS::Process::Queue->new(%$self, force => 1)->enqueue_cpan;
  WWW::CPANTS::Process::Analysis->new(%$self)->process_queue;

  $worepan->root->remove;
}

__END__

=head1 NAME

fix_analysis.pl - analyze dists separately to fix

=head1 USAGE

  fix_analysis.pl --cpan /path/to/cpan P/PA/PAUSEID/DistA-0.01.tar.gz
