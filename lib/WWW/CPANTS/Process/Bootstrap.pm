package WWW::CPANTS::Process::Bootstrap;

use strict;
use warnings;
use WWW::CPANTS::AppRoot;
use WWW::CPANTS::Log;
use Furl;
use Archive::Zip;
use CSS::LESS::Filter;
use String::CamelCase qw/decamelize/;

sub new {
  my $class = shift;
  bless {@_}, $class;
}

sub update {
  my ($self, @target) = @_;

  my %map = map { (decamelize($_) => 1) } @target;

  my @methods = qw/
    fetch_bootstrap_master
    tweak_less_files
    run_grunt
    copy_files
  /;

  for my $method (@methods) {
    $self->$method if !@target or $map{$method};
  }
}

sub fetch_bootstrap_master {
  my $self = shift;
  my $zipball = file("tmp/bootstrap-master.zip");
  if (!$zipball->exists or $self->{force}) {
    $self->log(info => "downloading bootstrap-master");
    my $url = "https://github.com/twbs/bootstrap/archive/master.zip";
    my $furl = Furl->new;
    my $res = $furl->get($url);
    die $res->status_line unless $res->is_success;
    $zipball->save($res->content, binmode => 1);
  }

  my $zip = Archive::Zip->new("$zipball") or die "Can't read $zipball";
  for ($zip->members) {
#    next unless $_->fileName =~ /\.(png|less|js)$/;
    $_->extractToFileNamed(file("tmp/", $_->fileName)->absolute);
  }
}

sub run_grunt {
  my $self = shift;

  $self->log(info => "processing");

  chdir dir("tmp/bootstrap-master");
  system("npm install") and warn "grunt error: $?";
  system("grunt clean") and warn "grunt error: $?";
  system("grunt dist-css") and warn "grunt error: $?";
  system("grunt dist-js") and warn "grunt error: $?";
  system("grunt copy:fonts") and warn "grunt error: $?";
}

sub copy_files {
  my $self = shift;
  for my $dir (qw/css fonts js/) {
    my $distdir = dir("tmp/bootstrap-master/dist/$dir");
    for my $file ($distdir->children) {
      $file->copy_to(dir("public/$dir"));
    }
  }

}

sub tweak_less_files {
  my $self = shift;

  $self->log(info => "tweaking less files");

  $self->{less_dir} = dir("tmp/bootstrap-master/less");

  my @not_used = qw/
    accordion
    carousel
    hero-unit
    modals
    popovers
    progress-bars
    thumbnails
    wells
  /;

  # remove less files not used now
  $self->{less_dir}->file("$_.less")->remove for @not_used;

  # remove imports
  $self->_tweak_less_file(bootstrap => [
    '@import' => sub {
      my $value = shift;
      for (@not_used) {
        return if $value =~ /['"]$_.less['"]/;
      }
      $value;
    },
  ]);

  $self->_tweak_less_file(breadcrumbs => [
    '.breadcrumb { .active { font-weight:' => 'bold',
  ]);

  # override tablesorter stuff
  $self->_tweak_less_file(tables => [
    'table.tablesorter { background-color:' => '@white',
    'table.tablesorter { font-size:' => '8pt',
    'table.tablesorter thead tr th { background-color:' => '@theme-color-lighter',
    'table.tablesorter tfoot tr th { background-color:' => '@theme-color-lighter',
    'table.tablesorter { width:' => '100%',
    'table.tablesorter thead tr .header { cursor:' => 'pointer',
    'table.tablesorter tbody td { vertical-align:' => 'top',

    ".table-striped tbody > tr:nth-child(odd) > td, .table-striped tbody > tr:nth-child(odd) > th { background-color:" => '@white',
    ".table-striped tbody > tr:nth-child(even) > td, .table-striped tbody > tr:nth-child(even) > th { background-color:" => '@table-bg-accent',
  ]);

  $self->_tweak_less_file(variables => [
    '@white:' => '#fff',
    '@theme-color:' => '#7BB4F3',
    '@theme-color-highlight:' => 'darken(spin(@theme-color, -60), 30%)',
    '@theme-color-lightest:' => 'lighten(@theme-color, (95% - lightness(@theme-color)))',
    '@theme-color-lighter:' => 'lighten(@theme-color, (90% - lightness(@theme-color)))',
    '@theme-color-light:' => 'lighten(@theme-color, (85% - lightness(@theme-color)))',
    '@theme-color-darkest:' => 'darken(@theme-color, 30%)',
    '@theme-color-darker:' => 'darken(@theme-color, 20%)',
    '@theme-color-dark:' => 'darken(@theme-color, 10%)',

    '@link-color:' => '@theme-color-dark',
    '@link-hover-color:' => '@theme-color-darker',
    '@navbar-default-link-active-color:' => '@theme-color',
    '@navbar-default-bg:' => '@theme-color-dark',
    '@navbar-default-link-color:' => '@white',
    '@navbar-default-link-hover-color:' => '@theme-color-darkest',
    '@navbar-default-brand-hover-color:' => '@theme-color-darkest',
    '@headings-color:' => '@theme-color-darkest',

    '@breadcrumb-bg:' => '@theme-color-lightest',
    '@breadcrumb-color:' => '@link-color',
    '@breadcrumb-active-color:' => '@theme-color-highlight',

    '@table-bg-accent:' => '@theme-color-lightest',
    '@table-bg-hover:' => '@theme-color-lightest',
    '@table-border-color:' => '@theme-color-light',
  ]);

  my %color_mapping = (
    lbrocard => '#ff7300',
    book => '#ff66cc',
    barbie => '#663376',
    rjbs => '#bb00ff',
    vpit => '#ffb033',
    pjcj => '#71558e',
  );

  for my $author (keys %color_mapping) {
    my $file = $self->{less_dir}->file("theme_$author.less");
    unlink $file if -f $file;
    $self->_tweak_less_file("theme_$author" => [
      "\@theme-color-$author:" => $color_mapping{$author},
      "\@theme-color-highlight-$author:" => "darken(spin(\@theme-color-$author, -60), 30%)",
      "\@theme-color-lightest-$author:" => "lighten(\@theme-color-$author, (95% - lightness(\@theme-color-$author)))",
      "\@theme-color-lighter-$author:" => "lighten(\@theme-color-$author, (90% - lightness(\@theme-color-$author)))",
      "\@theme-color-light-$author:" => "lighten(\@theme-color-$author, (85% - lightness(\@theme-color-$author)))",
      "\@theme-color-darkest-$author:" => "darken(\@theme-color-$author, 40%)",
      "\@theme-color-darker-$author:" => "darken(\@theme-color-$author, 20%)",
      "\@theme-color-dark-$author:" => "darken(\@theme-color-$author, 15%)",

      "\@link-color-$author:" => "\@theme-color-dark-$author",
      "\@link-hover-color-$author:" => "\@theme-color-darker-$author",
      "\@headings-color-$author:" => "\@theme-color-darkest-$author",
      "\@table-border-color-$author:" => "\@theme-color-light-$author",
      "\@table-bg-accent-$author:" => "\@theme-color-lightest-$author",
      "\@table-bg-hover-$author:" => "\@theme-color-lightest-$author",
      "\@breadcrumb-bg-$author:" => "\@theme-color-lightest-$author",
      "\@breadcrumb-color-$author:" => "\@link-color-$author",
      "\@breadcrumb-active-color-$author:" => "\@theme-color-highlight-$author",

      ".pause-$author { a { color: " => "\@link-color-$author",
      ".pause-$author { a:hover { color: " => "\@link-hover-color-$author",
      ".pause-$author { h1,h2,h3,h4,h5,h6 { color:" => "\@headings-color-$author",
      ".pause-$author { .table th,.table td { border:" => "1px solid \@table-border-color-$author",
      ".pause-$author { .table tbody + tbody { border-top:" => "2px solid \@table-border-color-$author",
      ".pause-$author { .table-bordered { border:" => "1px solid \@table-border-color-$author",
      ".pause-$author { .table-bordered th, .table-bordered td { border:" => "1px solid \@table-border-color-$author",
      ".pause-$author { .table-striped tbody > tr:nth-child(even) > td, .table-striped tbody > tr:nth-child(even) > th { background-color:" => "\@table-bg-accent-$author",
      ".pause-$author { .table-hover tbody > tr:hover td, .table-hover tbody tr:hover > th { background-color:" => "\@table-bg-hover-$author",
      ".pause-$author { table.tablesorter thead tr th, table.tablesorter thoot tr th { background-color:" => "\@theme-color-lighter-$author",
      ".pause-$author { table.tablesorter { border-color:" => "\@theme-color-lighter-$author",
      ".pause-$author { .breadcrumb { background-color:" => "\@breadcrumb-bg-$author",
      ".pause-$author { .breadcrumb { .active { color:" => "\@breadcrumb-active-color-$author",
      ".pause-$author { .alert-info { color:" => "\@theme-color-dark-$author",
      ".pause-$author { .alert-info { background-color:" => "\@theme-color-lightest-$author",
      ".pause-$author { .alert-info { border-color:" => "\@theme-color-light-$author",
      ".pause-$author { .navbar-default { background-color:" => "\@theme-color-light-$author",
      ".pause-$author { .navbar-default { border-color:" => "\@theme-color-light-$author",
      ".pause-$author { .navbar-default { a:hover,a:active { color:" => "\@theme-color-dark-$author",
      ".pause-$author { .navbar-default .navbar-nav { li { a:hover,a:active { color:" => "\@theme-color-dark-$author",
    ]);
  }

  {
    my $file = $self->{less_dir}->file("bootstrap.less");
    my $less = $file->slurp;
    for my $author (keys %color_mapping) {
      unless ($less =~ /theme_$author/) {
        $less .= qq{\@import "theme_$author.less";\n};
      }
    }
    $file->save($less);
  }
}

sub _tweak_less_file {
  my ($self, $name, $filters) = @_;
  $self->log(info => "tweaking $name");
  my $file = $self->{less_dir}->file("$name.less");
  my $less = $file->exists ? $file->slurp : '';
  my $filter = CSS::LESS::Filter->new;
  $filter->add(@$filters);
  $less = $filter->process($less, {mode => 'append'});
  $file->save($less);
}

1;

__END__

=head1 NAME

WWW::CPANTS::Process::Bootstrap

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 METHODS

=head2 new
=head2 concat_js
=head2 fetch_bootstrap_master
=head2 run_recess
=head2 tweak_less_files
=head2 update

=head1 AUTHOR

Kenichi Ishigaki, E<lt>ishigaki@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 by Kenichi Ishigaki.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
