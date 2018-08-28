package WWW::CPANTS;

use Modern::Perl;
use experimental 'signatures';
use Carp;
use Data::Dump;
use Syntax::Keyword::Try;
use JSON::PP (); # to avoid warnings when Cpanel::JSON::XS is loaded somewhere earlier

our $VERSION = '4.00';
our $CONTEXT;

sub import ($class, @args) {
  Modern::Perl->import('2015');
  experimental->import(qw/signatures/);
  Syntax::Keyword::Try->import;
  Carp->export_to_level(1, @_);
  my $caller = caller;
  no strict 'refs';
  *{"$caller\::dump"} = \&Data::Dump::dump;
}

sub is_testing ($class) { $ENV{HARNESS_ACTIVE} ? 1 : 0 }

sub context ($class) { $CONTEXT }

1;

__END__

=encoding utf-8

=head1 NAME

WWW::CPANTS - new CPANTS frontend/backend

=head1 DESCRIPTION

This is a proof of concept for the CPANTS website refactoring from scratch. Everything is discarded except for Module::CPANTS::Kwalitee and its components (and some of the Site templates for now).

=head1 AUTHOR

Kenichi Ishigaki, E<lt>ishigaki@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2012-2015 by Kenichi Ishigaki.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
