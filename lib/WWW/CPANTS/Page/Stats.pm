package WWW::CPANTS::Page::Stats;

use strict;
use warnings;
use WWW::CPANTS::Util::JSON;
use Module::Find;
use String::CamelCase qw/decamelize/;

sub title { 'Stats' }

sub load_data { slurp_json('page/stats') }

sub create_data {
  my $class = shift;

  my @pages;
  for my $package (findallmod 'WWW::CPANTS::Page::Stats') {
    eval "require $package" or next;
    (my $path = $package) =~ s/^WWW::CPANTS::Page::Stats:://;
    $path =~ s|::|/|g;
    $path = (length $path < 3) ? lc $path : decamelize($path);
    push @pages, {title => $package->title, path => "/stats/$path"};
  }
  save_json('page/stats', {pages => [sort {$a->{title} cmp $b->{title}} @pages]});
}

1;

__END__

=head1 NAME

WWW::CPANTS::Page::Stats

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 METHODS

=head2 title
=head2 load_data
=head2 create_data

=head1 AUTHOR

Kenichi Ishigaki, E<lt>ishigaki@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2013 by Kenichi Ishigaki.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
