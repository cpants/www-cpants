use strict;
use warnings;
use WWW::CPANTS::Test;
use WWW::CPANTS::Analyze;
use IO::Capture::Stderr;

my @paths = qw(
  CDRAKE/SysTray-0.13.tar.gz
  DBROBINS/Event-IO-0.01.tar.gz
  DHUDES/HTTP-CheckProxy-0.1.tar.gz
  DHUDES/HTTP-CheckProxy-0.2.tar.gz
  DHUDES/HTTP-CheckProxy-0.4.tar.gz
  DHUDES/HTTPD-ADS-0.6.tar.gz
  DHUDES/HTTPD-ADS-0.6.1.tar.gz
  DHUDES/HTTPD-ADS-0.7.tar.gz
  DHUDES/HTTPD-ADS-0.8.tar.gz
  DHUDES/IP-Route-Reject-0.2.tar.gz
  DHUDES/IP-Route-Reject-0.3.tar.gz
  DHUDES/Net-IP-Route-Reject-0.5.tar.gz
  DHUDES/Net-IP-Route-Reject-0.5_1.tar.gz
  DMAKI/DateTime-Util-Astro-0.02.tar.gz
  DROLSKY/Alzabo-GUI-Mason-0.1.tar.gz
  DROLSKY/DateTime-Format-Builder-0.7802.tar.gz
  DROLSKY/DateTime-Locale-0.08.tar.gz
  DROLSKY/DateTime-Locale-0.09.tar.gz
  JHOBLITT/DateTime-Calendar-Mayan-0.0601.tar.gz
  JOUKE/AAC-Pvoice-0.01.tar.gz
  MNDRIX/Class-DBI-MSAccess-0.01.tar.gz
  RCAPUTO/POE-0.28.tar.gz
  RCLAMP/Email-Folder-0.82.tar.gz
  RCLAMP/Email-Folder-0.83.tar.gz
  RCLAMP/Pod-Coverage-0.14.tar.gz
  RCLAMP/Text-vFile-asData-0.01.tar.gz
  SCHUMACK/CircuitLayout-0.06.tar.gz
  SCHUMACK/CircuitLayout-0.07.tar.gz
  SCHUMACK/GDS2-2.03.tar.gz
  SCHUMACK/GDS2-2.04.tar.gz
  SRSHAH/Test-Distribution-1.12.tar.gz
  SRSHAH/Test-Distribution-1.13.tar.gz
  SRSHAH/Test-Distribution-1.14.tar.gz
  TOMI/URI-Title-0.3.tar.gz
);

my $mirror = setup_mirror(@paths);

my $analyzer = WWW::CPANTS::Analyze->new;
for my $path (@paths) {
  my $capture = IO::Capture::Stderr->new;
  $capture->start;
  my $context = $analyzer->analyze(dist => $mirror->file($path));
  $capture->stop;
  my $err = $capture->read;
  ok !$err, "no warnings are captured";
  note $err if $err;
}

done_testing;
