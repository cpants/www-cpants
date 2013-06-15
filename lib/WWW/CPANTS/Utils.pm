package WWW::CPANTS::Utils;

use strict;
use warnings;
use Exporter::Lite;
use Time::Piece;
use WWW::CPANTS::AppRoot;

our @EXPORT = qw/
  date datetime
  decimal percent
  kb
/;

sub date {
  my $time = gmtime(shift);
  $time->ymd;
}

sub datetime {
  my $time = gmtime(shift);
  $time->ymd . ' ' . $time->hms;
}

sub decimal {
  my $decimal = shift;
  sprintf '%0.2f', int($decimal * 100 + 0.5) / 100;
}

sub percent {
  my ($numerator, $denominator) = @_;
  decimal($numerator / ($denominator || 100) * 100);
}

sub kb {
  my $byte = shift;
  my $kb = 1000; # or better use Kibibyte?
  if ($byte > $kb * $kb) {
    return decimal($byte / ($kb * $kb)) . ' MB'
  }
  elsif ($byte > $kb) {
    return decimal($byte / $kb) . ' KB';
  }
  return $byte . ' bytes';
}

sub hide_internal {
  my $str = shift;
  my $root = WWW::CPANTS::AppRoot::approot->stringify;
  $str =~ s!$ENV{HOME}/perl5/perlbrew/perls/[^/]+/lib/(site_perl/)?5\.\d+\.\d+/!$1lib/!g;
  $str =~ s!$ENV{HOME}/(backpan|cpan/)!$1!g;
  $str =~ s!$root/tmp/analysis/[^/]+/[^/]+/!!g;
  $str =~ s!$root/extlib/[^/]+/!!g;
  $str =~ s!$ENV{HOME}/!!g;
  $str =~ s!$root/!!g;
  $str;
}

1;

__END__

=head1 NAME

WWW::CPANTS::Utils

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 METHODS

=head2 date, datetime
=head2 decimal
=head2 percent
=head2 kb
=head2 hide_internal

=head1 AUTHOR

Kenichi Ishigaki, E<lt>ishigaki@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 by Kenichi Ishigaki.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
