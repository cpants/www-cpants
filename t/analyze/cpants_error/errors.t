use strict;
use warnings;
use Test::More;
use WorePAN;

plan skip_all => 'not yet done';

my @files = (
  # Odd number of elements in anonymous hash at (eval 6241) line 1.
  'TSCH/Glib-1.180.tar.gz',

  # Can't extract at lib/WWW/CPANTS/Analyze/Context.pm line 115.
  'COLINK/STATISTICS-DESCRIPTIVE-2.1.TAR.GZ',
  'CDONLEY/NET-LDAPAPI-1.31.TAR.GZ',
  'DSUGAL/VMS-MISC-1_00.ZIP',

  # error: Unsupported compression combination: read 6, write 0
  'PHOENIXL/extensible_report_generator_1.13.zip',
  'PHOENIXL/extensible_report_generator_1.12.zip',

  # IO error: Can't open file: Permission denied
  'RJSRI/QXP-Validate-1.0.zip',

  # format error: can't find EOCD signature
  'ROOTKWOK/Win32-SysPrivilege-v0.02.zip',
  'JBAKER/mod_perl-1.07_04-bin-bindist1-i386-win32-vc5.zip',
  'NREICHEN/eicndhcpd_11.zip',

  # Can't extract 
  'NREICHEN/eicndhcpd_v11_src.ZIP',
  'ASTILLER/DBD_RDB-1_13.ZIP',
  'ASTILLER/DBD_RDB-1_14.ZIP',
  'ASTILLER/DBD_RDB-1_15.ZIP',
  'COLINK/STATISTICS-DESCRIPTIVE-2.1.TAR.GZ',

  # Making block device 're portable.
  'ANGERSTEI/Net-Ping-Network-1.55.tar.gz',

  # Unsuccessful lstat on filename containing newline 
  'KGB/PGPLOT-2.02.tar.gz',
  'KGB/PGPLOT-2.01.tar.gz',
  'KULCHENKO/SOAP-Lite-0.55.zip',

  # Code point 0x1A4DE4 is not Unicode, all \p{} matches fail
  'LUSHE/HTML-Template-Ex-0.05.tar.gz',
  'LUSHE/HTML-Template-Ex-0.06.tar.gz',
  'KIMOTO/DBIx-Custom-0.1643.tar.gz',

  # Cannot read compressed format in tar-mode
  'CAPOEIRAB/WWW-Salesforce-0.03.tar.gz',
  'CAPOEIRAB/WWW-Salesforce-Simple-0.07.tar.gz',
  'CAPOEIRAB/WWW-Salesforce-0.04.tar.gz',
  'DCANTRELL/Tie-Hash-Longest-1.0.reupload.tar.gz',
  'DCANTRELL/Tie-Hash-Longest-1.0.tar.gz',
  'ILYAZ/etext0.6.0.tar.gz',
  'ILYAZ/etext/etext0.6.0.tar.gz',
  'OWEN/Math-RPN-1.03.tar.gz',
  'OWEN/Math-RPN-1.05.tar.gz',
  'FREMAN/Device-Inverter-Aurora.0.01.tar.gz',
  'CLCL/WebService-NiigataUnyu-v0.0.3.tar.gz',
  'CLCL/WebService-NiigataUnyu-v0.0.1.tar.gz',
  'CLCL/WebService-SagawaKyubin-v0.0.2.tar.gz',
  'CLCL/WebService-SagawaKyubin-v0.0.3.tar.gz',
  'CLCL/WebService-SagawaKyubin-0.0.1.tar.gz',
  'CLCL/WebService-KuronekoYamato-v0.0.4.tar.gz',
  'MANOWAR/RadiusPerl-0.07.tar.gz',
  'PETERGAL/PGForth1.1.tar.gz',
  'MARCLANG/ParallelUserAgent-2.37.tar.gz',
  'PYTHIAN/DBD-Oracle-1.24.tar.gz',
  'DAUNAY/oEdtk.20070321.v0.31.tar.gz',
  'SCHOEN/R3-conn-0.20.tar.gz',
  'SCHOEN/R3-func-0.20.tar.gz',
  'SCHOEN/R3-rfcapi-0.21.tar.gz',
  'SCHOEN/R3-0.01.tar.gz',
  'SCHOEN/R3-itab-0.20.tar.gz',
  'SCHOEN/R3-rfcapi-0.20.tar.gz',
  'LBENDAVID/DBD-TSM/DBD-TSM-0.11.tar.gz',
  'LBENDAVID/DBD-TSM-0.12.tar.gz',
  'NYAKNYAN/HTTP-Server-EV-0.21.tar.gz',
  'KHW/Unicode-Casing-09.tar.gz',
  'KORSANI/Log-Funlog-0.88.tar.gz',
  'KORSANI/Log-Funlog-0.89.tar.gz',

  # checksum error
  'CAM/File-SetSize-0.1.tar.gz',
  'TSTANLEY/Logger-Simple-1.06.tar.gz',
  'TSTANLEY/Config-Yacp-1.00.tar.gz',
  'TSTANLEY/Logger-Simple-1.03.tar.gz',
  'TSTANLEY/Logger-Simple-1.08.tar.gz',
  'TSTANLEY/Logger-Simple-1.05.tar.gz',
  'TSTANLEY/Logger-Simple-1.04.tar.gz',
  'OKAMOTO/MIME-Types-0.03.tar.gz',

  # Read error on tarfile
  'TRIAS/Fame-2.0d.tar.gz',
  'DROBERTS/File-Repl-0.4.tar.gz',
  'DROBERTS/File-Repl0.4.tar.gz',
  'ILTZU/Tie-CharArray-1.00.tar.gz',
  'TSTANLEY/Games-QuizTaker-1.tar.gz',
  'TSTANLEY/Config-Yacp-1.1.tar.gz',
  'TSTANLEY/Logger-Simple-1.081.tar.gz',
  'OESTERHOL/Term-Screen-Wizard-0.46.tar.gz',
  'OESTERHOL/Term-Screen-Wizard-0.45.tar.gz',
  'OESTERHOL/Term-Screen-Wizard-0.47.tar.gz',
  'OESTERHOL/Term-Screen-ReadLine-0.33.tar.gz',
  'OESTERHOL/Term-Screen-Wizard-0.20.tar.gz',
  'OESTERHOL/Term-Screen-Wizard-0.48.tar.gz',

  # Cannot read enough bytes from the tarfile
  'DRBEAN/Games-Tournament-Swiss-004/tables-0.04.tar.gz',
  'TSTANLEY/Games-QuizTaker-1.08.tar.gz',
  'ILYAZ/modules/Math-Pari-2.0305_01080604.tar.gz',

  # Couldn't read chunk at offset unknown
  'ILTZU/Tie-CharArray-0.02.tar.gz',
  'TSTANLEY/Logger-Simple-1.02.tar.gz',
  'TSTANLEY/Games-QuizTaker-1.03.tar.gz',
  'TSTANLEY/Logger-Simple-1.07.tar.gz',
  'OKAMOTO/MIME-Types-0.02.tar.gz',

  # format error: file is too short
  'ILYAZ/os2/perl5.00301.os2.zip',
);

done_testing;
