package WWW::CPANTS::Util::DistnameInfo;

use WWW::CPANTS;
use Exporter qw/import/;

our @EXPORT = qw/distinfo distname_info/;

# borrowed (and tweaked) from CPAN::DistnameInfo::new (of 0.12)
sub distinfo ($file) {
  my $path = $file;
  $path =~ s,//+,/,g;

  my ($distv, $ext) = $path =~ m!([^/]+)\.(tar\.(?:g?z|bz2)|zip|tgz)$!;
  return unless $ext; # not an archive

  # PATCHED: take care of /Perl6/ directory
  ($path, undef, undef, my $pause_id, my $is_perl6) = $path =~ m|^(?:(?:(?:.*?/)?authors/)?id/)?(([A-Z])/(\2[A-Z0-9\-])/(\3[A-Z0-9\-]*)/(Perl6/)?.*$)|;

  return {"perl6" => 1} if $is_perl6;

  my ($dist, $version, $dev) = distname_info($distv);

  return {
    filename => "$file",
    path => $path,
    cpanid => $pause_id,
    dist => $dist,
    version => $version,
    maturity => $dev ? 'developer' : 'released',
    distvname => $distv,
    extension => $ext,
  };
}

# borrowed (and tweaked) from CPAN::DistnameInfo 0.12
sub distname_info ($distv) {
  my ($dist, $version) = $distv =~ /^
    ((?:[-+.]*(?:[A-Za-z0-9]+|(?<=\D)_|_(?=\D))*
     (?:
      [A-Za-z](?=[^A-Za-z]|$)
      |
      \d(?=-)
     )(?<![._-][vV])
    )+)(.*)
  $/xs or return ($distv, undef, undef);

  if ($dist =~ /-undef\z/ and ! length $version) {
    $dist =~ s/-undef\z//;
  }

  # Remove potential -withoutworldwriteables suffix
  $version =~ s/-withoutworldwriteables$//;

  # PATCHED: added "v?" (GH #1)
  if ($version =~ /^(-[Vv].*)-(v?\d.*)/) {
    # Catch names like Unicode-Collate-Standard-V3_1_1-0.1
    # where the V3_1_1 is part of the distname
    $dist .= $1;
    $version = $2;
  }

  # PATCHED: added "v?" (GH #1)
  if ($version =~ /(.+_.*)-(v?\d.*)/) {
    # Catch names like Task-Deprecations5_14-1.00.tar.gz where the 5_14 is
    # part of the distname. However, names like libao-perl_0.03-1.tar.gz
    # should still have 0.03-1 as their version.
    $dist .= $1;
    $version = $2;
  }

  # Normalize the Dist.pm-1.23 convention which CGI.pm and
  # a few others use.
  $dist =~ s{\.pm$}{};

  $version = $1
    if !length $version and $dist =~ s/-(\d+\w)$//;

  $version = $1 . $version
    if $version =~ /^\d+$/ and $dist =~ s/-(\w+)$//;

  if ($version =~ /\d\.\d/) {
    $version =~ s/^[-_.]+//;
  }
  else {
    $version =~ s/^[-_]+//;
  }

  my $dev;
  if (length $version) {
    if ($distv =~ /^perl-?\d+\.(\d+)(?:\D(\d+))?(-(?:TRIAL|RC)\d+)?$/) {
      $dev = 1 if (($1 > 6 and $1 & 1) or ($2 and $2 >= 50)) or $3;
    }
    elsif ($version =~ /\d\D\d+_\d/ or $version =~ /-TRIAL/) {
      $dev = 1;
    }
  }
  else {
    $version = undef;
  }

  ($dist, $version, $dev);
}

1;
