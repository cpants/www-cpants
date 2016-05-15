package WWW::CPANTS::Bin::Model::CPAN;

use WWW::CPANTS;
use WWW::CPANTS::Bin::Util;
use WWW::CPANTS::Bin::Util::UserAgent;

sub new ($class, $root = config('cpan_dir')) {
  my $path = Path::Tiny::path($root);
  if (!-d $path->child('authors/id')) {
    carp "$path seems not a CPAN mirror";
    return;
  }
  bless {path => $path}, $class;
}

sub child ($self, $path) { $self->{path}->child($path) }

sub author_dir ($self, $pause_id) {
  $self->child(join '/', "authors/id", substr($pause_id, 0, 1), substr($pause_id, 0, 2), $pause_id);
}

sub authors_id_dir ($self) {
  $self->child("authors/id");
}

sub list_files_in_recent_json ($self, $type = '1h') {
  my $path = $self->child("RECENT-$type.json");
  return unless -f $path;

  my $json = $path->slurp_utf8;
  my @files;
  for (@{ decode_json($json)->{recent} }) {
    next unless $_->{path} =~ s!^authors/id/!!;
    next unless $_->{path} =~ /\.(?:tar\.(?:g?z|bz2)|zip|tgz)$/;
    push @files, $_;
  }
  \@files;
}

sub path_to_packages_details ($self) { 'modules/02packages.details.txt' }

sub has_packages_details ($self) {
  my $file = $self->child($self->path_to_packages_details);
  return 1 if -f $file;
  if (-f "$file.gz") {
    $self->gunzip("$file.gz" => $file);
    return 1 if -f $file;
  }
  return;
}

sub fetch_packages_details ($self) {
  my $path = $self->path_to_packages_details;
  my $file = $self->child($self->path_to_packages_details);
  $file->parent->mkpath;
  my $base_url = config('cpan_url');
  mirror("$base_url/$path.gz" => "$file.gz");
  $self->gunzip("$file.gz" => $file);
}

sub list_packages_details ($self) {
  return unless $self->has_packages_details;
  my $file = $self->child($self->path_to_packages_details);

  open my $fh, '<', $file or croak "$file: $!";
  my @rows;
  my $seen_header;
  while(defined(my $line = <$fh>)) {
    chomp $line;
    if (!$seen_header && $line =~ /^$/) { $seen_header = 1; next; }
    next unless $seen_header;
    my ($module, $version, $path) = split /\s+/, $line;
    my $distinfo = distinfo($path);
    push @rows, {
      module => $module,
      version => $version,
      path => $path,
      uid => path_uid($path),
      dist => $distinfo->{dist},
    };
  }
  \@rows;
}

sub indexed_path_for ($self, $module) {
  my $lc_module = lc $module;
  if (!$self->{indexed_paths}) {
    my $list = $self->list_packages_details;
    my %paths;
    for (@$list) {
      $paths{lc $_->{module}} = $_->{path};
    }
    $self->{indexed_paths} = \%paths;
  }
  return $self->{indexed_paths}{$lc_module} if exists $self->{indexed_paths}{$lc_module};
  return;
}

sub gunzip ($self, $from, $to) {
  require IO::Uncompress::Gunzip;
  IO::Uncompress::Gunzip::gunzip("$from" => "$to") or croak "$from: $IO::Uncompress::Gunzip::GunzipError";
}

sub path_to_permissions ($self) { 'modules/06perms.txt' }

sub has_permissions ($self) {
  my $file = $self->child($self->path_to_permissions);
  return 1 if -f $file;
  if (-f "$file.gz") {
    $self->gunzip("$file.gz" => $file);
    return 1 if -f $file;
  }
  return;
}

sub fetch_permissions ($self) {
  my $path = $self->path_to_permissions;
  my $file = $self->child($path);
  $file->parent->mkpath;
  my $base_url = config('cpan_url');
  mirror("$base_url/$path.gz" => "$file.gz");
  $self->gunzip("$file.gz" => $file);
}

sub list_permissions ($self) {
  return unless $self->has_permissions;
  my $file = $self->child($self->path_to_permissions);

  open my $fh, '<', $file or croak "$file: $!";
  my @rows;
  my $seen_header;
  while(defined(my $line = <$fh>)) {
    chomp $line;
    if (!$seen_header && $line =~ /^$/) { $seen_header = 1; next; }
    next unless $seen_header;
    my ($module, $pause_id, $perm) = split /,/, $line;
    push @rows, { module => $module, pause_id => $pause_id };
  }
  \@rows;
}

sub can_upload ($self, $author, $module) {
  my $uc_author = uc $author;
  my $lc_module = lc $module;
  if (!$self->{permissions}) {
    my $list = $self->list_permissions;
    my %permissions;
    for (@$list) {
      $permissions{lc $_->{module}}{uc $_->{pause_id}} = 1;
    }
    $self->{permissions} = \%permissions;
  }
  return 1 if !exists $self->{permissions}{$lc_module};
  return 1 if exists $self->{permissions}{$lc_module}{$uc_author};
  return;
}

sub path_to_whois ($self) { 'authors/00whois.xml' }

sub has_whois ($self) {
  -f $self->child($self->path_to_whois) ? 1 : 0;
}

sub list_whois ($self) {
  return unless $self->has_whois;
  my $file = $self->child($self->path_to_whois);

  $XML::SAX::ParserPackage = "XML::LibXML::SAX";
  require Parse::CPAN::Whois;
  my @authors;
  for my $author (Parse::CPAN::Whois->new("$file")->authors) {
    push @authors, {
      pause_id => $author->{id},
      name => $author->{fullname},
      ascii_name => $author->{asciiname} // $author->{fullname},
      email => $author->{email} // '',
      homepage => $author->{homepage} // '',
      has_cpandir => $author->{has_cpandir} // 0,
      introduced => $author->{introduced} // 0,
    };
  }
  \@authors;
}

sub fetch_whois ($self) {
  my $path = $self->path_to_whois;
  my $file = $self->child($path);
  $file->parent->mkpath;
  my $base_url = config('cpan_url');
  mirror("$base_url/$path" => $file);
}

1;
