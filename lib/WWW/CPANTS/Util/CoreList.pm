package WWW::CPANTS::Util::CoreList;

use strict;
use warnings;
use Exporter::Lite;
use Module::CoreList;

our @EXPORT = qw/is_core/;

my $perl_version = $^V->numify;
my $list;

sub perl_version {
  if (@_) {
    $perl_version = shift;
  }
  $list = $Module::CoreList::version{$perl_version};
  $perl_version;
}

sub is_core {
  $list ||= $Module::CoreList::version{$perl_version};

  exists $list->{$_[0]} ? 1 : 0;
}

1;

__END__

=head1 NAME

WWW::CPANTS::Util::CoreList

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 METHODS

=head2 is_core
=head2 perl_version

=head1 AUTHOR

Kenichi Ishigaki, E<lt>ishigaki@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 by Kenichi Ishigaki.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
