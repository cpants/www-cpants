package WWW::CPANTS::Utils;

use strict;
use warnings;
use Exporter::Lite;
use Time::Piece;
use WWW::CPANTS::AppRoot;

our @EXPORT = qw/
  date datetime
  decimal percent
  kb hide_internal
  link_to_package
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
  my $decimal = shift || 0;
  sprintf '%0.2f', int($decimal * 100 + 0.5) / 100;
}

sub percent {
  my ($numerator, $denominator) = @_;
  decimal($numerator / ($denominator || 100) * 100);
}

sub kb {
  my $byte = shift || 0;
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
  (my $home = $root) =~ s|^(/home/[^/]+)/.+|$1|;
  $str =~ s!$home/perl5/perlbrew/perls/[^/]+/lib/(site_perl/)?5\.\d+\.\d+/!$1lib/!g;
  $str =~ s!$home/((?:backpan|cpan)/)!$1!g;
  $str =~ s!$root/tmp/analyze/[^/]+/[^/]+/!!g;
  $str =~ s!$root/extlib/[^/]+/!!g;
  $str =~ s!$root/!!g;
  $str =~ s!$home/!!g;
  $str;
}

sub link_to_package {
  my $package = shift;
  my $base_url = "https://github.com/cpants";

  my ($basename) = $package =~ /::([^:]+)$/;
  if ($package =~ /::SiteKwalitee::/) {
    return "$base_url/Module-CPANTS-SiteKwalitee/blob/master/lib/Module/CPANTS/SiteKwalitee/$basename.pm";
  } elsif ($package =~ /::Kwalitee::/) {
    return "$base_url/Module-CPANTS-Analyse/blob/master/lib/Module/CPANTS/Kwalitee/$basename.pm";
  }
  return "#";
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
