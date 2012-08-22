use strict;
use warnings;
use WWW::CPANTS::Test;

plan skip_all => 'todo';

# plain text
my @prereq_with_spaces = qw(
  T/TN/TNAGA/PHP-Functions-File-0.04.tar.gz
  B/BA/BARBIE/Labyrinth-Plugin-Requests-1.00.tar.gz
  B/BA/BARBIE/Labyrinth-Demo-1.00.tar.gz
  P/PE/PEREZ/XML-RSS-FOXSports-0.02.tar.gz
  D/DA/DAROLD/Apache2-ModProxyPerlHtml-3.3.tar.gz
  D/DA/DAVIDRW/WWW-Netflix-API-0.10.tar.gz
  D/DA/DAVIDRW/WWW-Netflix-API-0.10.tar.gz
  D/DB/DBROWNING/Business-Shipping-3.1.0.tar.gz
  D/DB/DBROWNING/Business-Shipping-2.03.tar.gz
  R/RO/RONALDWS/LockFile-NetLock-0.32.tar.gz
);

# prereq version has spaces (and signs)
my @prereq_version_with_spaces = qw(
  A/AR/ARCOLF/Math-Fractal-DLA-0.21.tar.gz
  A/AR/AREGGIORI/Apache-SPARQL-0.22.tar.gz
  A/AR/AREGGIORI/Apache-SPARQL-RDFStore-0.3.tar.gz
  A/AR/AREGGIORI/Apache-Session-DBMS-0.32.tar.gz
  A/AS/ASB/MIME-Lite-HT-HTML-0.03.tar.gz
  A/AS/ASCOPE/Apache-XPointer-1.1.tar.gz
  A/AS/ASCOPE/Apache-XPointer-RDQL-1.1.tar.gz
  A/AS/ASCOPE/Flickr-Upload-Dopplr-0.3.tar.gz
  A/AS/ASCOPE/Flickr-Upload-FireEagle-0.1.tar.gz
  A/AS/ASCOPE/Geo-Geotude-1.0.tar.gz
  A/AS/ASCOPE/MT-Import-Base-1.01.tar.gz
  A/AS/ASCOPE/MT-Import-Mbox-1.01.tar.gz
  A/AS/ASCOPE/Net-Delicious-Export-1.2.tar.gz
  A/AS/ASCOPE/Net-Delicious-Export-Post-XBEL-1.4.tar.gz
  A/AS/ASCOPE/Net-Flickr-Geo-0.72.tar.gz
  A/AS/ASCOPE/Net-Flickr-Simile-0.1.tar.gz
  A/AS/ASCOPE/Net-Google-1.0.tar.gz
  A/AS/ASCOPE/Net-ModestMaps-1.1.tar.gz
  A/AS/ASCOPE/Net-Moo-0.11.tar.gz
  A/AS/ASCOPE/XML-Generator-RFC822-RDF-1.1.tar.gz
  A/AS/ASCOPE/XML-Generator-vCard-1.3.tar.gz
  A/AS/ASCOPE/XML-Generator-vCard-Base-1.0.tar.gz
  A/AS/ASCOPE/XML-Generator-vCard-RDF-1.4.tar.gz
  A/AS/ASCOPE/XML-XBEL-1.4.tar.gz
  B/BD/BDUGGAN/Class-DBI-Audit-0.04.tar.gz
  B/BG/BGARBER/Net-Random-QRBG-0.02.tar.gz
  B/BG/BGILMORE/Colloquy-Push-0.01.tar.gz
  C/CL/CLACO/Net-Blogger-1.02.tar.gz
  C/CS/CSJEWELL/Perl-Dist-WiX-1.250.tar.gz
  D/DA/DANDV/MojoMojo-0.999033.tar.gz
  D/DM/DMAKI/Class-DBI-Plugin-Senna-0.01.tar.gz
  D/DM/DMAKI/Tie-Senna-0.02.tar.gz
  D/DM/DMANURA/SQL-Interpolate-0.30.tar.gz
  D/DM/DMANURA/SQL-Interpolate-0.32.tar.gz
  D/DM/DMLOND/Google-Spreadsheet-Agent-0.02.tar.gz
  D/DU/DUPUISARN/Slackware-Slackget-0.17.tar.gz
  D/DY/DYLUNIO/Gwybodaeth-0.02.tar.gz
  E/ER/ERMEYERS/WWW-Blogger-2008.1021.tar.gz
  F/FR/FROTZ/REST-Resource-0.5.2.4.tar.gz
  F/FX/FXFX/Integrator-Module-Build-1.057.tar.gz
  J/JA/JASPAX/Lingua-Phonology-0.3503.tar.gz
  J/JD/JDALBERG/Log-Log4perl-Appender-Spread-0.03.tar.gz
  J/JL/JLAVALLEE/Acme-Magic-Pony-0.03.tar.gz
  J/JL/JLMARTIN/Catalyst-Authentication-Credential-Authen-Simple-0.07.tar.gz
  M/MA/MARKLE/CGI-FormBuilder-Mail-FormatMultiPart-1.0.6.tar.gz
  M/MI/MINTER/Net-Raccdoc-1.3.tar.gz
  M/MI/MITTI/PDF-Report-Table-1.01.tar.gz
  M/MJ/MJONDET/WebService-Eulerian-Analytics-0.8.tar.gz
  M/MR/MRAMBERG/MojoMojo-0.999029.tar.gz
  M/MR/MRAMBERG/MojoMojo-0.999041.tar.gz
  N/NU/NUFFIN/Devel-FIXME-0.01.tar.gz
  N/NU/NUFFIN/MPEG-Audio-Frame-0.09.tar.gz
  N/NU/NUFFIN/Object-Meta-Plugin-0.01.tar.gz
  N/NU/NUFFIN/Package-Relative-0.01.tar.gz
  N/NU/NUFFIN/Pod-Wrap-0.01.tar.gz
  N/NU/NUFFIN/Test-TAP-HTMLMatrix-0.09.tar.gz
  P/PA/PAJOUT/XML-Trivial-0.06.tar.gz
  P/PC/PCHRISTE/Options-1.5.2.tgz
  P/PJ/PJB/MIDI-ALSA-1.14.tar.gz
  P/PJ/PJB/MIDI-SoundFont-1.04.tar.gz
  P/PJ/PJB/Math-WalshTransform-1.17.tar.gz
  R/RD/RDROUSIES/Catalyst-Plugin-Authentication-Credential-CHAP-0.03.tar.gz
  T/TF/TFOUCART/WWW-Sucksub-Attila-0.06.tar.gz
  T/TF/TFOUCART/WWW-Sucksub-Divxstation-0.01.tar.gz
  T/TF/TFOUCART/WWW-Sucksub-Divxstation-0.04.tar.gz
  T/TF/TFOUCART/WWW-Sucksub-Extratitles-0.01.tar.gz
  T/TF/TFOUCART/WWW-Sucksub-Frigo-0.03.tar.gz
  T/TF/TFOUCART/WWW-Sucksub-Vostfree-0.05.tar.gz
  T/TL/TLBDK/IO-Buffered-1.00.tar.gz
  T/TL/TLBDK/IO-EventMux-2.02.tar.gz
  T/TL/TLBDK/IO-EventMux-Socket-MsgHdr-0.02.tar.gz
  V/VM/VMORAL/Module-Build-IkiWiki-0.0.6.tar.gz
);

done_testing;
