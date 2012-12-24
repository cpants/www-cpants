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
    run_recess
    concat_js
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
    my $url = "https://github.com/twitter/bootstrap/archive/master.zip";
    my $furl = Furl->new;
    my $res = $furl->get($url);
    die $res->status_line unless $res->is_success;
    $zipball->save($res->content, binmode => 1);
  }

  my $zip = Archive::Zip->new("$zipball") or die "Can't read $zipball";
  for ($zip->members) {
    next unless $_->fileName =~ /\.(png|less|js)$/;
    $_->extractToFileNamed(file("tmp/", $_->fileName)->absolute);
  }
}

sub run_recess {
  my $self = shift;

  $self->log(info => "processing less files");

  for (qw/bootstrap responsive theme_lbrocard theme_book/) {
    my $out = $_ eq 'responsive' ? 'bootstrap-responsive' : $_;
    system('@recess', '--compile', file("tmp/bootstrap-master/less/$_.less")->absolute, '>', file("public/css/$out.css")->absolute) and warn "recess error: $_: $?";
  }
}

sub concat_js {
  my $self = shift;

  $self->log(info => "concatenating js files");

  my @names = qw(
    transition
    alert
    button
    collapse
    dropdown
    tooltip
    tab
  );
  my @not_used = qw(
    affix
    carousel
    modal
    popover
    scrollspy
    typeahead
  );

  my $js = '';
  for (@names) {
    $js .= file("tmp/bootstrap-master/js/bootstrap-$_.js")->slurp  . "\n";
  }
  file('public/js/bootstrap.js')->save($js);
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
    '.breadcrumb { background-color:' => '@breadcrumbBackground',
    '.breadcrumb { .divider { color:' => '@breadcrumbDivider',
    '.breadcrumb { li { color:' => '@breadcrumbDivider',
    '.breadcrumb { .active { color:' => '@breadcrumbActive',
    '.breadcrumb { .active { font-weight:' => 'bold',
  ]);

  # override tablesorter stuff
  $self->_tweak_less_file(tables => [
    'table.tablesorter { background-color:' => '@white',
    'table.tablesorter { font-size:' => '8pt',
    'table.tablesorter thead tr th { background-color:' => '@themeColorLighter',
    'table.tablesorter tfoot tr th { background-color:' => '@themeColorLighter',
    'table.tablesorter { width:' => '100%',
    'table.tablesorter thead tr .header { cursor:' => 'pointer',
    'table.tablesorter tbody td { vertical-align:' => 'top',
  ]);

  $self->_tweak_less_file(variables => [
    '@themeColorHighlight:' => 'darken(spin(@themeColor, -60), 30%)',
    '@themeColorLightest:' => 'lighten(@themeColor, 98% - lightness(@themeColor))',
    '@themeColorLighter:' => 'lighten(@themeColor, 90% - lightness(@themeColor))',
    '@themeColorLight:' => 'lighten(@themeColor, 85% - lightness(@themeColor))',
    '@themeColorDarkest:' => 'darken(@themeColor, 30%)',
    '@themeColorDarker:' => 'darken(@themeColor, 20%)',
    '@themeColorDark:' => 'darken(@themeColor, 10%)',

    '@linkColor:' => '@themeColorDark',
    '@linkColorHover:' => '@themeColorDarker',
    '@navbarBackgroundHighlight:' => '@themeColor',
    '@navbarBackground:' => '@themeColorDark',
    '@navbarLinkColor:' => '@white',
    '@navbarLinkColorHover:' => '@themeColorDarkest',
    '@headingsColor:' => '@themeColorDarkest',
    '@breadcrumbBackground:' => '@themeColorLightest',
    '@breadcrumbDivider:' => '@linkColor',
    '@breadcrumbActive:' => '@themeColorHighlight',
    '@tableBackgroundAccent:' => '@themeColorLightest',
    '@tableBackgroundHover:' => '@themeColorLightest',
    '@tableBorder:' => '@themeColorLight',
  ]);

  $self->_tweak_less_file(bootstrap => [
    '@themeColor:' => '#7BB4F3',
  ]);
  $self->_tweak_less_file(responsive => [
    '@themeColor:' => '#7BB4F3',
  ]);

  {
    my $bootstrap = $self->{less_dir}->file("bootstrap.less");
    for (qw/lbrocard book/) {
      my $file = $bootstrap->parent->file("theme_$_.less");
      $bootstrap->copy_to($file);
      my $less = $file->slurp;
      my ($copyright, $body) = split /\n\n/, $less, 2;
      $less = "$copyright\n\n.pause-$_ {\n$body\n}\n";
      $file->save($less);
    }
  }

  $self->_tweak_less_file(theme_lbrocard => [
    '.pause-lbrocard { @themeColor:' => '#ff7300',
  ]);

  $self->_tweak_less_file(theme_book => [
    '.pause-book { @themeColor:' => '#ff66cc',
  ]);
}

sub _tweak_less_file {
  my ($self, $name, $filters) = @_;
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

=head1 AUTHOR

Kenichi Ishigaki, E<lt>ishigaki@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 by Kenichi Ishigaki.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
