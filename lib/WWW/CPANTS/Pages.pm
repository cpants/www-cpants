package WWW::CPANTS::Pages;

use strict;
use warnings;
use WWW::CPANTS::Log;
use Module::Find qw/findallmod/;
use Sub::Install qw/reinstall_sub/;
use Timer::Simple;

our %LOADED;

sub import {
  my $class = shift;
  my $caller = caller;
  for my $module (findallmod 'WWW::CPANTS::Page') {
    next if $module =~ /[^A-Za-z0-9_:]/; # ignore temporary files
    eval "require $module; 1" or do { warn "$module: $@"; next };
    $LOADED{$module} = 1;
  }
  reinstall_sub({ into => $caller, code => 'page' });
  reinstall_sub({ into => $caller, code => 'load_page' });
}

sub page {
  my $id = shift;
  my $package = "WWW::CPANTS::Page::".$id;
  return unless $LOADED{$package};
  $package;
}

sub load_page {
  my $page = page(shift) or return;
  $page->load_data(@_);
}

sub loaded { keys %LOADED }

sub update {
  my ($self, @target) = @_;

  my $timer = Timer::Simple->new;
  for my $module (sort keys %LOADED) {
    if (@target) {
      next unless grep { $module =~ /::$_/ } @target;
    }
    my $code = $module->can('create_data') or next;
    $self->log(info => "processing $module");
    eval { $code->() };
    warn $@ if $@;
    $self->log(debug => "$module: ".$timer->elapsed."s");
    $timer->restart;
  }
}

1;

__END__

=head1 NAME

WWW::CPANTS::Pages

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 METHODS

=head2 page
=head2 load_page
=head2 loaded
=head2 update

=head1 AUTHOR

Kenichi Ishigaki, E<lt>ishigaki@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 by Kenichi Ishigaki.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
