package WWW::CPANTS::Process::GzipStaticFiles;

use strict;
use warnings;
use WWW::CPANTS::AppRoot;
use IO::Compress::Gzip qw/gzip $GzipError/;

sub new {
  my ($class, %args) = @_;

  bless \%args, $class;
}

sub compress {
  my $self = shift;

  dir('public')->recurse(callback => sub {
    my $e = shift;
    return unless -f $e;
    return if $e =~ /\.gz$/;
    gzip "$e" => "$e.gz" or $self->log(warn => "$GzipError: $e");
  });
}

1;

__END__

=head1 NAME

WWW::CPANTS::Process::GzipStaticFiles

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 METHODS

=head2 new
=head2 compress

=head1 AUTHOR

Kenichi Ishigaki, E<lt>ishigaki@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 by Kenichi Ishigaki.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
