package WWW::CPANTS::DB;

use strict;
use warnings;
use Exporter::Lite;
use WWW::CPANTS::AppRoot;

our @EXPORT = qw/db/;

my %cache;

sub db {
  my $name = shift;
  unless ($cache{$name}) {
    my $package = "WWW::CPANTS::DB::$name";
    eval "require $package; 1" or die $@;
    my $db = $package->new;
    my $dbfile = $db->dbfile;
    warn "$dbfile does not exist\n" unless $dbfile->exists;
    $cache{$name} = $db;
  }
  if (@_) {
    my %args = ref $_[0] eq ref {} ? %{$_[0]} : @_;
    $cache{$name}{$_} = $args{$_} for keys %args;
  }
  $cache{$name};
}

sub fetch {
  my $class = shift;

  my ($opts, @names);
  for (@_) {
    if (ref $_) {
      $opts = $_;
    }
    else {
      push @names, $_;
    }
  }
  @names = qw/CPANTS Uploads/ unless @names;
  $opts ||= {};

  require LWP::UserAgent;
  require IO::Uncompress::Gunzip;
  my $ua = LWP::UserAgent->new(env_proxy => 1);
  $ua->show_progress(1) if $opts->{verbose};

  for my $name (@names) {
    my $db = db($name);
    my $dbfile = file('db', $db->dbname)->path;
    print STDERR "downloading $dbfile.gz from ".$db->url."\n";
    my $res = $ua->mirror($db->url, "$dbfile.gz");
    die $res->status_line."\n" if $res->is_error;

    IO::Uncompress::Gunzip::gunzip(
      "$dbfile.gz" => $dbfile,
      BinModeOut => 1,
    ) or die "gunzip failed: $IO::Uncompress::Gunzip::GunzipError";
  }
}

1;

__END__

=head1 NAME

WWW::Acme::CPANAuthors::DB

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 METHODS

=head2 db
=head2 fetch

=head1 AUTHOR

Kenichi Ishigaki, E<lt>ishigaki@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 by Kenichi Ishigaki.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
