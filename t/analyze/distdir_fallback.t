use strict;
use warnings;
use WWW::CPANTS::Test;
use WWW::CPANTS::Analyze;

my @paths = qw(
  V/VL/VLADB/cvs_init_1_01_.tar.gz
  V/VL/VLADB/cvs_init_1_01.tar.gz
  V/VL/VLADB/cvs_init_1_011.tar.gz
  Y/YE/YEWENBIN/deob-0.02.tar.gz
  C/CH/CHRISCHU/asm2htm-1.3.tar.gz
  C/CH/CHRISCHU/gif-info-1.1.tar.gz
  C/CH/CHETANG/API-ReviewBoard-0.1.tar.gz
  F/FE/FERNANDES/Ppa_json2ppa_csv.pl-0.01.tar.gz
  D/DR/DRSTEVE/vimrc.tgz
  I/IA/IANPX/Stem-0.1.tar.gz
  I/ID/IDIVISION/nginx.pm.tar.gz
  I/ID/IDIVISION/nginx-0.0.1.tar.gz
  T/TU/TUSHAR/UniqueColumns_0.1.tar.gz
  F/FS/FSG/PGP-1.0.tar.gz
  P/PA/PARTICLE/testing-pause-upload-criteria-1.00.tar.gz
  E/EL/ELEONORA/ptkbl_1.0.tar.gz
  M/MA/MARSAB/Test123.pm.tar.gz
  B/BR/BRADAPP/PodParser-1.02.tar.gz
  B/BC/BCROWELL/LineByLine-1.0.tar.gz
  M/MA/MANOJKG/makeManPg.tar.gz
  S/SH/SHERZODR/Bundle-Config-Simple-0.01.tar.gz
  S/SC/SCHUBIGER/make2build-0.02.tar.gz
  S/SC/SCHUBIGER/make2build-0.01_01.tar.gz
  D/DA/DAMBAR/Catalyst-Plugin-Imager-0.01.tar.gz
  S/SC/SCHUBIGER/make2build-0.03.tar.gz
  S/SC/SCHUBIGER/make2build-0.01_02.tar.gz
  B/BP/BPRUDENT/VSS-1.0.3.tar.gz
  S/SE/SEOVISUAL/WebService-SEOmoz-FreeAPI-0.01.tar.gz
  L/LA/LAXEN/BBDB-1.2.tar.gz
  S/SA/SAULIUS/Date-Holidays-LT-0.01.tar.gz
  J/JO/JOHAYEK/app-xlstar-1-36.tar.gz
  G/GM/GMG/WTweb-0.1.tar.gz
  W/WI/WIHAA/EPS-2.00.tar.gz
  W/WI/WINKO/Parity-1.2.tar.gz
  W/WI/WINKO/BitCount-1.1.tar.gz
  W/WI/WINKO/Parext-1.1.tar.gz
  A/AR/ARDAN/historylogger.tar.gz
  W/WS/WSYVINSKI/Math-Vector-1.03.tar.gz
  W/WS/WSYVINSKI/Tie-TieConstant-1.01.tar.gz
  M/ME/MELONMAN/EasyPDF_0_02.tgz
  J/JE/JEROMEMCK/Net-ICQ-On-1.7.tar.gz
  J/JE/JEROMEMCK/ICQOn-1.6.tar.gz
  J/JE/JEROMEMCK/Net-ICQ-On-1.10.1.tar.gz
  J/JE/JEROMEMCK/Net-ICQ-On-1.6.tar.gz
  J/JE/JEROMEMCK/Net-ICQ-On-1.9.0.tar.gz
  J/JE/JEROMEMCK/Net-ICQ-On-1.9.4.tar.gz
  J/JE/JEROMEMCK/Net-ICQ-On-1.9.1.tar.gz
  J/JE/JEROMEMCK/Net-ICQ-On-1.10.2.tar.gz
  M/MF/MFU/ToFroDos-1.00.tar.gz
  J/JS/JSNBY/CDiso-1.0.0.2.tar.gz
  A/AN/ANATRA/tbl2html-v1.1.tar.gz
  R/RL/RLAUGHLIN/UDPmsg-0.10.tar.gz
  R/RL/RLAUGHLIN/UDPmsg-0.11.tar.gz
  R/RC/RCL/IPDevice-Allnet-ALL4000-0.10.tar.gz
  K/KG/KGJERDE/XPathToXML-0.01.tar.gz
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
