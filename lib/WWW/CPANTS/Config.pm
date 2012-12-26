package WWW::CPANTS::Config;

use strict;
use warnings;
use WWW::CPANTS::AppRoot;
use Path::Extended::Dir;

my %Config;

sub import {
  my $class = shift;

  return if $Config{_loaded};
  my $file = file("conf.pl");
  return unless $file->exists;

  my $conf = do "$file";

  unless (ref $conf eq ref {}) {
    warn "conf.pl must return a hash reference\n";
    return;
  }

  for (qw/cpan backpan/) {
    next unless exists $conf->{$_};
    if ($conf->{$_} =~ /^~/) {
      require File::HomeDir;
      $conf->{$_} =~ s/^~/File::HomeDir->my_home/e;
    }
    my $dir = Path::Extended::Dir->new($conf->{$_});
    if (!$dir->exists or !$dir->subdir('authors/id')->exists) {
      warn "$dir does not seem to be a $_ directory\n";
      delete $conf->{$_};
    }
  }

  %Config = (%$conf, _loaded => 1);
}

sub backpan { $Config{backpan} }
sub cpan    { $Config{cpan} }
sub local_addr { $Config{local_addr} || ['127.0.0.1'] }

1;

__END__

=head1 NAME

WWW::CPANTS::Config

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 METHODS

=head2 cpan
=head2 backpan
=head2 local_addr

=head1 AUTHOR

Kenichi Ishigaki, E<lt>ishigaki@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 by Kenichi Ishigaki.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
