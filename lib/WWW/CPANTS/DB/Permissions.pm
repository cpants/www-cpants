package WWW::CPANTS::DB::Permissions;

use strict;
use warnings;
use base 'WWW::CPANTS::DB::Base';

sub _columns {(
  [author => 'text primary key not null', {bulk_key => 1}],
  [packages => 'text'],
)}

1;

__END__

=head1 NAME

WWW::CPANTS::DB::Permissions

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 METHODS

=head2 new

=head1 AUTHOR

Kenichi Ishigaki, E<lt>ishigaki@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2013 by Kenichi Ishigaki.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
