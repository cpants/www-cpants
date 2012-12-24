use strict;
use warnings;
use WWW::CPANTS::Test;
use WWW::CPANTS::Analyze;
use Capture::Tiny qw/capture_stderr/;

my @paths = qw(
  C/CD/CDRAKE/SysTray-0.13.tar.gz
  D/DB/DBROBINS/Event-IO-0.01.tar.gz
  D/DH/DHUDES/HTTP-CheckProxy-0.1.tar.gz
  D/DH/DHUDES/HTTP-CheckProxy-0.2.tar.gz
  D/DH/DHUDES/HTTP-CheckProxy-0.4.tar.gz
  D/DH/DHUDES/HTTPD-ADS-0.6.tar.gz
  D/DH/DHUDES/HTTPD-ADS-0.6.1.tar.gz
  D/DH/DHUDES/HTTPD-ADS-0.7.tar.gz
  D/DH/DHUDES/HTTPD-ADS-0.8.tar.gz
  D/DH/DHUDES/IP-Route-Reject-0.2.tar.gz
  D/DH/DHUDES/IP-Route-Reject-0.3.tar.gz
  D/DH/DHUDES/Net-IP-Route-Reject-0.5.tar.gz
  D/DH/DHUDES/Net-IP-Route-Reject-0.5_1.tar.gz
  D/DM/DMAKI/DateTime-Util-Astro-0.02.tar.gz
  D/DR/DROLSKY/Alzabo-GUI-Mason-0.1.tar.gz
  D/DR/DROLSKY/DateTime-Format-Builder-0.7802.tar.gz
  D/DR/DROLSKY/DateTime-Locale-0.08.tar.gz
  D/DR/DROLSKY/DateTime-Locale-0.09.tar.gz
  J/JH/JHOBLITT/DateTime-Calendar-Mayan-0.0601.tar.gz
  J/JO/JOUKE/AAC-Pvoice-0.01.tar.gz
  M/MN/MNDRIX/Class-DBI-MSAccess-0.01.tar.gz
  R/RC/RCAPUTO/POE-0.28.tar.gz
  R/RC/RCLAMP/Email-Folder-0.82.tar.gz
  R/RC/RCLAMP/Email-Folder-0.83.tar.gz
  R/RC/RCLAMP/Pod-Coverage-0.14.tar.gz
  R/RC/RCLAMP/Text-vFile-asData-0.01.tar.gz
  S/SC/SCHUMACK/CircuitLayout-0.06.tar.gz
  S/SC/SCHUMACK/CircuitLayout-0.07.tar.gz
  S/SC/SCHUMACK/GDS2-2.03.tar.gz
  S/SC/SCHUMACK/GDS2-2.04.tar.gz
  S/SR/SRSHAH/Test-Distribution-1.12.tar.gz
  S/SR/SRSHAH/Test-Distribution-1.13.tar.gz
  S/SR/SRSHAH/Test-Distribution-1.14.tar.gz
  T/TO/TOMI/URI-Title-0.3.tar.gz
);

my $mirror = setup_mirror(@paths);

my $analyzer = WWW::CPANTS::Analyze->new;
for my $path (@paths) {
  my $err = capture_stderr {
    my $context = $analyzer->analyze(dist => $mirror->file($path));
  };
  ok !$err, "no warnings are captured";
  note $err if $err;
}

done_testing;
