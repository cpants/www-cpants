package WWW::CPANTS::Test;

use strict;
use warnings;
use Test::More;
use Test::Differences;
use WWW::CPANTS::AppRoot;
use WWW::CPANTS::Log;
use Exporter::Lite;
use WorePAN;

our @EXPORT = (
  @Test::More::EXPORT,
  @Test::Differences::EXPORT,
  qw/setup_mirror/,
);

my $worepan;
my $pid;

sub setup_mirror {
  my @files = @_;
  unless (@files) {
    @files = qw{
      I/IS/ISHIGAKI/Path-Extended-0.19.tar.gz
    };
  }

  my $mirror = dir('mirror')->mkdir;
  my $local_mirror = appdir('test_mirror')->mkdir;
  $worepan = WorePAN->new(
    root => $mirror->path,
    local_mirror => $local_mirror->path,
    files => \@files,
    no_network => 0,
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

END {
  if (Test::More->builder->is_passing) {
    if ($worepan and $pid == $$) {
      $worepan->root->remove;
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

=head2 new

=head1 AUTHOR

Kenichi Ishigaki, E<lt>ishigaki@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 by Kenichi Ishigaki.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
