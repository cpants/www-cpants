use strict;
use warnings;
use WWW::CPANTS::Test;

plan skip_all => 'todo';

# plain text
my @prereq_with_spaces = qw(
  TNAGA/PHP-Functions-File-0.04.tar.gz
  BARBIE/Labyrinth-Plugin-Requests-1.00.tar.gz
  BARBIE/Labyrinth-Demo-1.00.tar.gz
  PEREZ/XML-RSS-FOXSports-0.02.tar.gz
  DAROLD/Apache2-ModProxyPerlHtml-3.3.tar.gz
  DAVIDRW/WWW-Netflix-API-0.10.tar.gz
  DAVIDRW/WWW-Netflix-API-0.10.tar.gz
  DBROWNING/Business-Shipping-3.1.0.tar.gz
  DBROWNING/Business-Shipping-2.03.tar.gz
  RONALDWS/LockFile-NetLock-0.32.tar.gz
);

# prereq version has spaces (and signs)
my @prereq_version_with_spaces = qw(
  ARCOLF/Math-Fractal-DLA-0.21.tar.gz
  AREGGIORI/Apache-SPARQL-0.22.tar.gz
  AREGGIORI/Apache-SPARQL-RDFStore-0.3.tar.gz
  AREGGIORI/Apache-Session-DBMS-0.32.tar.gz
  ASB/MIME-Lite-HT-HTML-0.03.tar.gz
  ASCOPE/Apache-XPointer-1.1.tar.gz
  ASCOPE/Apache-XPointer-RDQL-1.1.tar.gz
  ASCOPE/Flickr-Upload-Dopplr-0.3.tar.gz
  ASCOPE/Flickr-Upload-FireEagle-0.1.tar.gz
  ASCOPE/Geo-Geotude-1.0.tar.gz
  ASCOPE/MT-Import-Base-1.01.tar.gz
  ASCOPE/MT-Import-Mbox-1.01.tar.gz
  ASCOPE/Net-Delicious-Export-1.2.tar.gz
  ASCOPE/Net-Delicious-Export-Post-XBEL-1.4.tar.gz
  ASCOPE/Net-Flickr-Geo-0.72.tar.gz
  ASCOPE/Net-Flickr-Simile-0.1.tar.gz
  ASCOPE/Net-Google-1.0.tar.gz
  ASCOPE/Net-ModestMaps-1.1.tar.gz
  ASCOPE/Net-Moo-0.11.tar.gz
  ASCOPE/XML-Generator-RFC822-RDF-1.1.tar.gz
  ASCOPE/XML-Generator-vCard-1.3.tar.gz
  ASCOPE/XML-Generator-vCard-Base-1.0.tar.gz
  ASCOPE/XML-Generator-vCard-RDF-1.4.tar.gz
  ASCOPE/XML-XBEL-1.4.tar.gz
  BDUGGAN/Class-DBI-Audit-0.04.tar.gz
  BGARBER/Net-Random-QRBG-0.02.tar.gz
  BGILMORE/Colloquy-Push-0.01.tar.gz
  CLACO/Net-Blogger-1.02.tar.gz
  CSJEWELL/Perl-Dist-WiX-1.250.tar.gz
  DANDV/MojoMojo-0.999033.tar.gz
  DMAKI/Class-DBI-Plugin-Senna-0.01.tar.gz
  DMAKI/Tie-Senna-0.02.tar.gz
  DMANURA/SQL-Interpolate-0.30.tar.gz
  DMANURA/SQL-Interpolate-0.32.tar.gz
  DMLOND/Google-Spreadsheet-Agent-0.02.tar.gz
  DUPUISARN/Slackware-Slackget-0.17.tar.gz
  DYLUNIO/Gwybodaeth-0.02.tar.gz
  ERMEYERS/WWW-Blogger-2008.1021.tar.gz
  FROTZ/REST-Resource-0.5.2.4.tar.gz
  FXFX/Integrator-Module-Build-1.057.tar.gz
  JASPAX/Lingua-Phonology-0.3503.tar.gz
  JDALBERG/Log-Log4perl-Appender-Spread-0.03.tar.gz
  JLAVALLEE/Acme-Magic-Pony-0.03.tar.gz
  JLMARTIN/Catalyst-Authentication-Credential-Authen-Simple-0.07.tar.gz
  MARKLE/CGI-FormBuilder-Mail-FormatMultiPart-1.0.6.tar.gz
  MINTER/Net-Raccdoc-1.3.tar.gz
  MITTI/PDF-Report-Table-1.01.tar.gz
  MJONDET/WebService-Eulerian-Analytics-0.8.tar.gz
  MRAMBERG/MojoMojo-0.999029.tar.gz
  MRAMBERG/MojoMojo-0.999041.tar.gz
  NUFFIN/Devel-FIXME-0.01.tar.gz
  NUFFIN/MPEG-Audio-Frame-0.09.tar.gz
  NUFFIN/Object-Meta-Plugin-0.01.tar.gz
  NUFFIN/Package-Relative-0.01.tar.gz
  NUFFIN/Pod-Wrap-0.01.tar.gz
  NUFFIN/Test-TAP-HTMLMatrix-0.09.tar.gz
  PAJOUT/XML-Trivial-0.06.tar.gz
  PCHRISTE/Options-1.5.2.tgz
  PJB/MIDI-ALSA-1.14.tar.gz
  PJB/MIDI-SoundFont-1.04.tar.gz
  PJB/Math-WalshTransform-1.17.tar.gz
  RDROUSIES/Catalyst-Plugin-Authentication-Credential-CHAP-0.03.tar.gz
  TFOUCART/WWW-Sucksub-Attila-0.06.tar.gz
  TFOUCART/WWW-Sucksub-Divxstation-0.01.tar.gz
  TFOUCART/WWW-Sucksub-Divxstation-0.04.tar.gz
  TFOUCART/WWW-Sucksub-Extratitles-0.01.tar.gz
  TFOUCART/WWW-Sucksub-Frigo-0.03.tar.gz
  TFOUCART/WWW-Sucksub-Vostfree-0.05.tar.gz
  TLBDK/IO-Buffered-1.00.tar.gz
  TLBDK/IO-EventMux-2.02.tar.gz
  TLBDK/IO-EventMux-Socket-MsgHdr-0.02.tar.gz
  VMORAL/Module-Build-IkiWiki-0.0.6.tar.gz
);

done_testing;
