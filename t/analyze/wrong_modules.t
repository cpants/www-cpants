use strict;
use warnings;
use Test::More;

plan skip_all => 'todo';

# These dists have a wrong module list for whatever reasons;
# some for XS, some for an old file layout, some
my @files_with_maybe_wrong_modules = (
  'A/AW/AWRIGLEY/Net-SMS-Web-0.015.tar.gz',
  #  Net::SMS::Web
  'B/BA/BAREFOOT/Test-File-1.34.tar.gz',
  #  Test::File
  'B/BD/BDFOY/Business-ISBN-2.05.tar.gz',
  #  Business::ISBN
  'B/BD/BDFOY/Business-ISSN-0.91.tar.gz',
  #  Business::ISSN
  'B/BD/BDFOY/CPAN-PackageDetails-0.25.tar.gz',
  #  CPAN::PackageDetails
  'B/BD/BDFOY/ConfigReader-Simple-1.28.tar.gz',
  #  ConfigReader::Simple
  'B/BD/BDFOY/Distribution-Guess-BuildSystem-0.12.tar.gz',
  #  Distribution::Guess::BuildSystem
  'B/BD/BDFOY/File-Find-Closures-1.09.tar.gz',
  #  File::Find::Closures
  'B/BD/BDFOY/HTTP-SimpleLinkChecker-1.16.tar.gz',
  #  HTTP::SimpleLinkChecker
  'B/BD/BDFOY/Mac-Path-Util-0.26.tar.gz',
  #  Mac::Path::Util
  'B/BD/BDFOY/Mac-iTunes-1.22.tar.gz',
  #  Mac::iTunes
  'B/BD/BDFOY/Module-Extract-Namespaces-0.14.tar.gz',
  #  Module::Extract::Namespaces
  'B/BD/BDFOY/MyCPAN-Indexer-1.28.tar.gz',
  #  MyCPAN::Indexer
  'B/BD/BDFOY/Netscape-Bookmarks-1.95.tar.gz',
  #  Netscape::Bookmarks
  'B/BD/BDFOY/Pod-InDesign-TaggedText-0.11.tar.gz',
  #  Pod::InDesign::TaggedText
  'B/BD/BDFOY/Test-Manifest-1.23.tar.gz',
  #  Test::Manifest
  'B/BD/BDFOY/Test-Prereq-1.037.tar.gz',
  #  Test::Prereq
  #  Test::Prereq::Build
  'B/BD/BDFOY/Test-URI-1.08.tar.gz',
  #  Test::URI
  'B/BD/BDFOY/Tie-Cycle-1.17.tar.gz',
  #  Tie::Cycle
  'B/BD/BDFOY/p5-Palm-1.012.tar.gz',
  #  Palm::PDB
  #  Palm::Raw
  #  Palm::StdAppInfo
  'B/BR/BRAINBUZ/IhasQuery-0.022.tar.gz',
  #  IhasQuery
  'C/CF/CFRANKS/HTML-Dojo-0.0403.0.tar.gz',
  #  HTML::Dojo
  'C/CH/CHISEL/Catalyst-Plugin-ErrorCatcher-0.0.8.12.tar.gz',
  #  Catalyst::Plugin::ErrorCatcher
  'C/CH/CHISEL/Template-Plugin-ForumCode-0.0.5.tar.gz',
  #  Template::Plugin::ForumCode
  'C/CH/CHM/PDL-2.4.11.tar.gz',
  #  PDL
  #  PDL::Core
  'C/CJ/CJFIELDS/BioPerl-1.6.901.tar.gz',
  #  Bio::Align::AlignI
  #  Bio::AlignIO
  #  Bio::AnnotatableI
  #  Bio::Annotation::Collection
  #  Bio::Annotation::SimpleValue
  #  Bio::Annotation::TypeManager
  #  Bio::AnnotationCollectionI
  #  Bio::AnnotationI
  #  Bio::DB::Flat
  #  Bio::DB::GenBank
  #  Bio::DB::SeqFeature::Store
  #  Bio::DescribableI
  #  Bio::FeatureHolderI
  #  Bio::IdentifiableI
  #  Bio::Index::Fasta
  #  Bio::LiveSeq::DNA
  #  Bio::LiveSeq::SeqI
  #  Bio::LocatableSeq
  #  Bio::Location::Atomic
  #  Bio::Location::CoordinatePolicyI
  #  Bio::Location::Fuzzy
  #  Bio::Location::FuzzyLocationI
  #  Bio::Location::Simple
  #  Bio::Location::WidestCoordPolicy
  #  Bio::LocationI
  #  Bio::Perl
  #  Bio::Phenotype::OMIM::OMIMparser
  #  Bio::PrimarySeq
  #  Bio::PrimarySeqI
  #  Bio::Range
  #  Bio::RangeI
  #  Bio::Root::Exception
  #  Bio::Root::IO
  #  Bio::Root::Root
  #  Bio::Root::RootI
  #  Bio::Root::Version
  #  Bio::SearchIO
  #  Bio::Seq
  #  Bio::Seq::LargePrimarySeq
  #  Bio::SeqI
  #  Bio::SeqIO
  #  Bio::SeqUtils
  #  Bio::SimpleAlign
  #  Bio::Structure::Chain
  #  Bio::Structure::Entry
  #  Bio::Structure::IO
  #  Bio::Structure::Model
  #  Bio::Structure::StructureI
  #  Bio::Symbol::Alphabet
  #  Bio::Symbol::AlphabetI
  #  Bio::Symbol::ProteinAlphabet
  #  Bio::Symbol::Symbol
  #  Bio::Symbol::SymbolI
  #  Bio::Tools::CodonTable
  #  Bio::Tools::IUPAC
  #  Bio::Tools::Run::StandAloneBlast
  #  Bio::Tools::SeqStats
  'C/CN/CNANDOR/Mac-Carbon-0.82.tar.gz',
  #  Mac::Processes
  'D/DD/DDUMONT/Puppet-Show-1.007.tar.gz',
  #  Puppet::Show
  'D/DD/DDUMONT/Puppet-VcsTools-History-1.004.tar.gz',
  #  Puppet::VcsTools::History
  'D/DJ/DJBECKETT/Redland-1.0.5.4.tar.gz',
  #  RDF::Redland
  'D/DO/DORMANDO/MogileFS-Server-2.64.tar.gz',
  #  MogileFS
  'D/DT/DTRISCHUK/Coro-Amazon-SimpleDB-0.04.tar.gz',
  #  Amazon::SimpleDB::Client
  'F/FL/FLORA/perl-5.15.4.tar.gz',
  #  Tie::StdScalar
  'G/GA/GAAS/perl-lisp-0.06.tar.gz',
  #  Lisp::Printer
  #  Lisp::Reader
  #  Lisp::Symbol
  'G/GI/GIRAFFED/Curses-1.28.tgz',
  #  Curses
  'G/GM/GMAX/Chess-PGN-Parse-0.19.tar.gz',
  #  Chess::PGN::Parse
  'G/GR/GRICHTER/Embperl-2.4.0.tar.gz',
  #  Embperl
  'G/GR/GROMMEL/Math-Random-0.71.tar.gz',
  #  Math::Random
  'H/HB/HBENGEN/Debian-Package-Make-0.04.tar.gz',
  #  Dpkg::Arch
  #  Dpkg::Cdata
  #  Dpkg::Version
  'J/JM/JMURPHY/ARSperl-1.91.tgz',
  #  ARS
  'J/JV/JV/Getopt-Long-2.38.tar.gz',
  #  Getopt::Long::Parser
  'K/KW/KWILLIAMS/Text-FillIn-0.05.tar.gz',
  #  Text::FillIn
  'L/LE/LEIRA/HTTP-Recorder-0.02.tar.gz',
  #  Test::Logger
  'M/MA/MARKSTOS/CGI-Application-3.31.tar.gz',
  #  TestApp
  'M/ML/MLEHMANN/common-sense-3.6.tar.gz',
  #  common::sense
  'M/ML/MLFISHER/pmtools-1.10.tar.gz',
  #  Devel::Loaded
  'N/NI/NI-S/Make-1.00.tar.gz',
  #  Make
  'P/PH/PHILIPS/DBIx-MyParsePP-0.50.tar.gz',
  #  DBIx::MyParsePP
  'P/PH/PHRED/mod_perl-2.0.7.tar.gz',
  #  Apache2::Access
  #  Apache2::CmdParms
  #  Apache2::Connection
  #  Apache2::Directive
  #  Apache2::FilterRec
  #  Apache2::Module
  #  Apache2::Process
  #  Apache2::Response
  #  Apache2::ServerRec
  #  Apache2::ServerUtil
  #  Apache2::SubRequest
  #  Apache2::URI
  #  Apache2::Util
  #  APR::Finfo
  #  APR::Pool
  #  APR::String
  #  APR::Table
  #  APR::UUID
  #  ModPerl::Util
  'P/PO/POLETTIX/HTTP-Cookies-Mozilla-2.03.tar.gz',
  #  HTTP::Cookies::Mozilla
  'S/SH/SHLOMIF/XML-LibXML-2.0004.tar.gz',
  #  XML::LibXML::Element
  'S/SP/SPIDB/Net-ext-1.011.tar.gz',
  #  Net::TCP
  #  Net::UDP
  'S/SR/SREZIC/Tk-804.030.tar.gz',
  #  Tk::ColorEditor
  'T/TA/TAYERS/Algorithm-LUHN-1.00.tar.gz',
  #  Algorithm::LUHN
  'T/TA/TAYERS/Business-CINS-1.13.tar.gz',
  #  Business::CINS
  'T/TE/TEVERETT/Win32-Security-0.50.tar.gz',
  #  Win32::Security::SID
  'T/TG/TGUMMELS/File-MkTemp-1.0.6.tar.gz',
  #  File::MkTemp
  'T/TI/TIMB/DBI-1.622.tar.gz',
  #  DBD::File::dr
  'T/TO/TOBYINK/perl5-tobyink-0.001.tar.gz',
  #  perl5::tobyink
  'T/TP/TPABA/Term-Screen/Term-Screen-Uni-0.04.tar.gz',
  #  Term::Screen::Uni
  'Y/YU/YUMPY/Shell-POSIX-Select-0.05.tar.gz',
  #  Shell::POSIX::Select
  'Z/ZU/ZUMMO/Amazon-SNS-1.0.tar.gz',
  #  Amazon::SNS::Topic
);

done_testing;
