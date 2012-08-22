package WWW::CPANTS::DB::Uploads;

use strict;
use warnings;
use base 'WWW::CPANTS::DB::Base';

sub dbname { 'uploads.db' }
sub schema { return <<'SCHEMA';
create table if not exists uploads (
  type text,
  author text,
  dist text,
  version text,
  filename text,
  released integer
);

create index if not exists dist_idx on uploads (dist);
SCHEMA
}

sub cpan_dists {
  my $self = shift;
  $self->fetchall_1('select dist || "-" || version from uploads where type = "cpan"');
}

sub latest_dists {
  my $self = shift;
  $self->fetchall_1('select dist || "-" || version from (select * from uploads order by released asc) where type = "cpan" group by dist order by released');
}

1;

__END__

=head1 NAME

WWW::CPANTS::DB::Uploads

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
