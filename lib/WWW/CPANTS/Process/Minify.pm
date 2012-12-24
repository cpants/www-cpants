package WWW::CPANTS::Process::Minify;

use strict;
use warnings;
use WWW::CPANTS::AppRoot;
use JavaScript::Minifier::XS;
use CSS::Minifier::XS;

sub new {
  my ($class, %args) = @_;

  bless \%args, $class;
}

sub minify {
  my $self = shift;

  my (@css_all, @js_all);
  dir('templates')->recurse(callback => sub {
    my $e = shift;
    return unless -f $e;
    my $tmpl = $e->slurp;
    push @css_all, $tmpl =~ /^%=\s*stylesheet\s+['"]\/?([^"']+)['"]/mg;
    push @js_all, $tmpl =~ /^%=\s*javascript\s+['"]\/?([^"']+)['"]/mg;
  });

  my %seen;
  my $combined_js = '';
  for (@js_all) {
    next if /cpants\.min\.js$/;
    next if /html5shiv\.js$/; # IE only
    next if $seen{$_}++;
    my $file = file('public', $_);
    unless ($file->exists) {
      warn "$_ does not exist\n";
    }
    my $js = $file->slurp;
    my $minified_js = eval { JavaScript::Minifier::XS::minify($js) };
    if ($@) {
      warn "$_: $@";
      $minified_js = $js;
    }
    $combined_js .= "// $_\n$minified_js\n";
  }

  file('public/js/cpants.min.js')->save($combined_js);

  my $combined_css = '';
  for (@css_all) {
    next if /cpants\.min\.css$/;
    next if $seen{$_}++;
    my $file = file('public', $_);
    unless ($file->exists) {
      warn "$_ does not exist\n";
    }
    my $css = $file->slurp;
    my $minified_css = eval { CSS::Minifier::XS::minify($css) };
    if ($@) {
      warn "$_: $@";
      $minified_css = $css;
    }
    $combined_css .= "/* $_ */\n$minified_css\n";
  }

  file('public/css/cpants.min.css')->save($combined_css);
}

1;

__END__

=head1 NAME

WWW::CPANTS::Process::Minify

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 METHODS

=head2 new
=head2 minify

=head1 AUTHOR

Kenichi Ishigaki, E<lt>ishigaki@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 by Kenichi Ishigaki.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
