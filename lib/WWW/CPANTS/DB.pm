package WWW::CPANTS::DB;

use strict;
use warnings;
use Exporter::Lite;
use WWW::CPANTS::AppRoot;
use Module::Find;

our @EXPORT = qw/db db_r/;

my %loaded;

sub db {
  my $name = shift;
  unless ($loaded{$name}) {
    my $package = "WWW::CPANTS::DB::$name";
    eval "require $package; 1" or die $@;
    $loaded{$name} = $package;
  }
  $loaded{$name}->new(@_);
}

sub db_r {
  my $db = db(@_, readonly => 1);
  unless (-s $db->dbfile) {
    unlink $db->dbfile if -f $db->dbfile;
    die $db->dbname." does not exist\n";
  }
  $db;
}

sub load_all {
  for my $package (usesub 'WWW::CPANTS::DB') {
    my ($name) = $package =~ /::(\w+)$/;
    next if $name eq 'Base';
    $loaded{$name} = $package;
  }
}

sub loaded { sort keys %loaded }

1;

__END__

=head1 NAME

WWW::CPANTS::DB

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 METHODS

=head2 db, db_r
=head2 load_all
=head2 loaded

=head1 AUTHOR

Kenichi Ishigaki, E<lt>ishigaki@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 by Kenichi Ishigaki.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
