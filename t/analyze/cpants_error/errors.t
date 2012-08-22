use strict;
use warnings;
use Test::More;
use WorePAN;

plan skip_all => 'not yet done';

my @files = (
  # Odd number of elements in anonymous hash at (eval 6241) line 1.
  'T/TS/TSCH/Glib-1.180.tar.gz',

  # Can't extract at lib/WWW/CPANTS/Analyze/Context.pm line 115.
  'C/CO/COLINK/STATISTICS-DESCRIPTIVE-2.1.TAR.GZ',
  'C/CD/CDONLEY/NET-LDAPAPI-1.31.TAR.GZ',
  'D/DS/DSUGAL/VMS-MISC-1_00.ZIP',

  # error: Unsupported compression combination: read 6, write 0
  'P/PH/PHOENIXL/extensible_report_generator_1.13.zip',
  'P/PH/PHOENIXL/extensible_report_generator_1.12.zip',

  # IO error: Can't open file: Permission denied
  'R/RJ/RJSRI/QXP-Validate-1.0.zip',

  # format error: can't find EOCD signature
  'R/RO/ROOTKWOK/Win32-SysPrivilege-v0.02.zip',
  'J/JB/JBAKER/mod_perl-1.07_04-bin-bindist1-i386-win32-vc5.zip',
  'N/NR/NREICHEN/eicndhcpd_11.zip',

  # Can't extract 
  'N/NR/NREICHEN/eicndhcpd_v11_src.ZIP',
  'A/AS/ASTILLER/DBD_RDB-1_13.ZIP',
  'A/AS/ASTILLER/DBD_RDB-1_14.ZIP',
  'A/AS/ASTILLER/DBD_RDB-1_15.ZIP',
  'C/CO/COLINK/STATISTICS-DESCRIPTIVE-2.1.TAR.GZ',

  # Making block device 're portable.
  'A/AN/ANGERSTEI/Net-Ping-Network-1.55.tar.gz',

  # Unsuccessful lstat on filename containing newline 
  'K/KG/KGB/PGPLOT-2.02.tar.gz',
  'K/KG/KGB/PGPLOT-2.01.tar.gz',
  'K/KU/KULCHENKO/SOAP-Lite-0.55.zip',

  # Code point 0x1A4DE4 is not Unicode, all \p{} matches fail
  'L/LU/LUSHE/HTML-Template-Ex-0.05.tar.gz',
  'L/LU/LUSHE/HTML-Template-Ex-0.06.tar.gz',
  'K/KI/KIMOTO/DBIx-Custom-0.1643.tar.gz',

  # Cannot read compressed format in tar-mode
  'C/CA/CAPOEIRAB/WWW-Salesforce-0.03.tar.gz',
  'C/CA/CAPOEIRAB/WWW-Salesforce-Simple-0.07.tar.gz',
  'C/CA/CAPOEIRAB/WWW-Salesforce-0.04.tar.gz',
  'D/DC/DCANTRELL/Tie-Hash-Longest-1.0.reupload.tar.gz',
  'D/DC/DCANTRELL/Tie-Hash-Longest-1.0.tar.gz',
  'I/IL/ILYAZ/etext0.6.0.tar.gz',
  'I/IL/ILYAZ/etext/etext0.6.0.tar.gz',
  'O/OW/OWEN/Math-RPN-1.03.tar.gz',
  'O/OW/OWEN/Math-RPN-1.05.tar.gz',
  'F/FR/FREMAN/Device-Inverter-Aurora.0.01.tar.gz',
  'C/CL/CLCL/WebService-NiigataUnyu-v0.0.3.tar.gz',
  'C/CL/CLCL/WebService-NiigataUnyu-v0.0.1.tar.gz',
  'C/CL/CLCL/WebService-SagawaKyubin-v0.0.2.tar.gz',
  'C/CL/CLCL/WebService-SagawaKyubin-v0.0.3.tar.gz',
  'C/CL/CLCL/WebService-SagawaKyubin-0.0.1.tar.gz',
  'C/CL/CLCL/WebService-KuronekoYamato-v0.0.4.tar.gz',
  'M/MA/MANOWAR/RadiusPerl-0.07.tar.gz',
  'P/PE/PETERGAL/PGForth1.1.tar.gz',
  'M/MA/MARCLANG/ParallelUserAgent-2.37.tar.gz',
  'P/PY/PYTHIAN/DBD-Oracle-1.24.tar.gz',
  'D/DA/DAUNAY/oEdtk.20070321.v0.31.tar.gz',
  'S/SC/SCHOEN/R3-conn-0.20.tar.gz',
  'S/SC/SCHOEN/R3-func-0.20.tar.gz',
  'S/SC/SCHOEN/R3-rfcapi-0.21.tar.gz',
  'S/SC/SCHOEN/R3-0.01.tar.gz',
  'S/SC/SCHOEN/R3-itab-0.20.tar.gz',
  'S/SC/SCHOEN/R3-rfcapi-0.20.tar.gz',
  'L/LB/LBENDAVID/DBD-TSM/DBD-TSM-0.11.tar.gz',
  'L/LB/LBENDAVID/DBD-TSM-0.12.tar.gz',
  'N/NY/NYAKNYAN/HTTP-Server-EV-0.21.tar.gz',
  'K/KH/KHW/Unicode-Casing-09.tar.gz',
  'K/KO/KORSANI/Log-Funlog-0.88.tar.gz',
  'K/KO/KORSANI/Log-Funlog-0.89.tar.gz',

  # checksum error
  'C/CA/CAM/File-SetSize-0.1.tar.gz',
  'T/TS/TSTANLEY/Logger-Simple-1.06.tar.gz',
  'T/TS/TSTANLEY/Config-Yacp-1.00.tar.gz',
  'T/TS/TSTANLEY/Logger-Simple-1.03.tar.gz',
  'T/TS/TSTANLEY/Logger-Simple-1.08.tar.gz',
  'T/TS/TSTANLEY/Logger-Simple-1.05.tar.gz',
  'T/TS/TSTANLEY/Logger-Simple-1.04.tar.gz',
  'O/OK/OKAMOTO/MIME-Types-0.03.tar.gz',

  # Read error on tarfile
  'T/TR/TRIAS/Fame-2.0d.tar.gz',
  'D/DR/DROBERTS/File-Repl-0.4.tar.gz',
  'D/DR/DROBERTS/File-Repl0.4.tar.gz',
  'I/IL/ILTZU/Tie-CharArray-1.00.tar.gz',
  'T/TS/TSTANLEY/Games-QuizTaker-1.tar.gz',
  'T/TS/TSTANLEY/Config-Yacp-1.1.tar.gz',
  'T/TS/TSTANLEY/Logger-Simple-1.081.tar.gz',
  'O/OE/OESTERHOL/Term-Screen-Wizard-0.46.tar.gz',
  'O/OE/OESTERHOL/Term-Screen-Wizard-0.45.tar.gz',
  'O/OE/OESTERHOL/Term-Screen-Wizard-0.47.tar.gz',
  'O/OE/OESTERHOL/Term-Screen-ReadLine-0.33.tar.gz',
  'O/OE/OESTERHOL/Term-Screen-Wizard-0.20.tar.gz',
  'O/OE/OESTERHOL/Term-Screen-Wizard-0.48.tar.gz',

  # Cannot read enough bytes from the tarfile
  'D/DR/DRBEAN/Games-Tournament-Swiss-004/tables-0.04.tar.gz',
  'T/TS/TSTANLEY/Games-QuizTaker-1.08.tar.gz',
  'I/IL/ILYAZ/modules/Math-Pari-2.0305_01080604.tar.gz',

  # Couldn't read chunk at offset unknown
  'I/IL/ILTZU/Tie-CharArray-0.02.tar.gz',
  'T/TS/TSTANLEY/Logger-Simple-1.02.tar.gz',
  'T/TS/TSTANLEY/Games-QuizTaker-1.03.tar.gz',
  'T/TS/TSTANLEY/Logger-Simple-1.07.tar.gz',
  'O/OK/OKAMOTO/MIME-Types-0.02.tar.gz',

  # format error: file is too short
  'I/IL/ILYAZ/os2/perl5.00301.os2.zip',
);

done_testing;
