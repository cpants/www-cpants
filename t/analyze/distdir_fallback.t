use strict;
use warnings;
use WWW::CPANTS::Test;
use WWW::CPANTS::Analyze;

my @paths = qw(
  VLADB/cvs_init_1_01_.tar.gz
  VLADB/cvs_init_1_01.tar.gz
  VLADB/cvs_init_1_011.tar.gz
  YEWENBIN/deob-0.02.tar.gz
  CHRISCHU/asm2htm-1.3.tar.gz
  CHRISCHU/gif-info-1.1.tar.gz
  CHETANG/API-ReviewBoard-0.1.tar.gz
  FERNANDES/Ppa_json2ppa_csv.pl-0.01.tar.gz
  DRSTEVE/vimrc.tgz
  IANPX/Stem-0.1.tar.gz
  IDIVISION/nginx.pm.tar.gz
  IDIVISION/nginx-0.0.1.tar.gz
  TUSHAR/UniqueColumns_0.1.tar.gz
  FSG/PGP-1.0.tar.gz
  PARTICLE/testing-pause-upload-criteria-1.00.tar.gz
  ELEONORA/ptkbl_1.0.tar.gz
  MARSAB/Test123.pm.tar.gz
  BRADAPP/PodParser-1.02.tar.gz
  BCROWELL/LineByLine-1.0.tar.gz
  MANOJKG/makeManPg.tar.gz
  SHERZODR/Bundle-Config-Simple-0.01.tar.gz
  SCHUBIGER/make2build-0.02.tar.gz
  SCHUBIGER/make2build-0.01_01.tar.gz
  DAMBAR/Catalyst-Plugin-Imager-0.01.tar.gz
  SCHUBIGER/make2build-0.03.tar.gz
  SCHUBIGER/make2build-0.01_02.tar.gz
  BPRUDENT/VSS-1.0.3.tar.gz
  SEOVISUAL/WebService-SEOmoz-FreeAPI-0.01.tar.gz
  LAXEN/BBDB-1.2.tar.gz
  SAULIUS/Date-Holidays-LT-0.01.tar.gz
  JOHAYEK/app-xlstar-1-36.tar.gz
  GMG/WTweb-0.1.tar.gz
  WIHAA/EPS-2.00.tar.gz
  WINKO/Parity-1.2.tar.gz
  WINKO/BitCount-1.1.tar.gz
  WINKO/Parext-1.1.tar.gz
  ARDAN/historylogger.tar.gz
  WSYVINSKI/Math-Vector-1.03.tar.gz
  WSYVINSKI/Tie-TieConstant-1.01.tar.gz
  MELONMAN/EasyPDF_0_02.tgz
  JEROMEMCK/Net-ICQ-On-1.7.tar.gz
  JEROMEMCK/ICQOn-1.6.tar.gz
  JEROMEMCK/Net-ICQ-On-1.10.1.tar.gz
  JEROMEMCK/Net-ICQ-On-1.6.tar.gz
  JEROMEMCK/Net-ICQ-On-1.9.0.tar.gz
  JEROMEMCK/Net-ICQ-On-1.9.4.tar.gz
  JEROMEMCK/Net-ICQ-On-1.9.1.tar.gz
  JEROMEMCK/Net-ICQ-On-1.10.2.tar.gz
  MFU/ToFroDos-1.00.tar.gz
  JSNBY/CDiso-1.0.0.2.tar.gz
  ANATRA/tbl2html-v1.1.tar.gz
  RLAUGHLIN/UDPmsg-0.10.tar.gz
  RLAUGHLIN/UDPmsg-0.11.tar.gz
  RCL/IPDevice-Allnet-ALL4000-0.10.tar.gz
  KGJERDE/XPathToXML-0.01.tar.gz
);

my $mirror = setup_mirror(@paths);

my $analyzer = WWW::CPANTS::Analyze->new;
for my $path (@paths) {
  my $file = $mirror->file($path);
  ok $file->exists, "$file exists";
  my $context = $analyzer->analyze(dist => $file);
  my $distdir = $context->distdir;
  ok $distdir && -d $distdir, "$path: distdir exists and is directory";
}

done_testing;
