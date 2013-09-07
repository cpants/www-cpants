package WWW::CPANTS::Page::Stats::ModuleInstall;

use strict;
use warnings;
use WWW::CPANTS::DB;
use WWW::CPANTS::JSON;

sub title { 'Module::Install' }

sub load_data { slurp_json('page/stats_module_install') }

sub create_data {
  my $class = shift;

  my $stats = db_r('ModuleInstall')->fetch_stats;

  save_json('page/stats_module_install', {
    stats => $stats,
  });
}

1;

__END__

=head1 NAME

WWW::CPANTS::Page::Stats::ModuleInstall

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
