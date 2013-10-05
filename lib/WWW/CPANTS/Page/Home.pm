package WWW::CPANTS::Page::Home;

use strict;
use warnings;
use WWW::CPANTS::AppRoot;
use WWW::CPANTS::DB;
use WWW::CPANTS::JSON;
use WWW::CPANTS::Extlib;
use String::CamelCase 'camelize';

sub title { 'CPANTS - A CPAN Testing Service' }

sub load_data { slurp_json('page/home') }

sub create_data {
  my $class = shift;
  my %data;

  $data{versions}{perl} = "$^V";

  my @modules_to_show_version;
  open my $fh, '<', appfile('cpanfile');
  while(<$fh>) {
    next unless /#\s*CHECK/;
    my ($package) = $_ =~ /requires\s*['"]([^'"]+)['"]/;
    push @modules_to_show_version, $package if $package;
  }
  push @modules_to_show_version, qw(
    Module::CPANTS::Analyse
    Module::CPANTS::SiteKwalitee
  );

  for my $package (sort @modules_to_show_version) {
    eval "require $package; 1" or die $@;
    $data{versions}{$package} = $package->VERSION . "";
  }

  $data{last_updated} = WWW::CPANTS::Utils::datetime(time);

  save_json('page/home', \%data);
}

1;

__END__

=head1 NAME

WWW::CPANTS::Page::Home

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 METHODS

=head2 title

=head2 load_data

=head2 create_data

=head1 AUTHOR

Kenichi Ishigaki, E<lt>ishigaki@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 by Kenichi Ishigaki.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
