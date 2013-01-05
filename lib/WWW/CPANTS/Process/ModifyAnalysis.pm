package WWW::CPANTS::Process::ModifyAnalysis;

use strict;
use warnings;
use WWW::CPANTS::DB;
use WWW::CPANTS::Log;
use WWW::CPANTS::Analyze::Context;
use WWW::CPANTS::JSON;

sub new {
  my ($class, %args) = @_;
  bless \%args, $class;
}

sub modify {
  my ($self, %args) = @_;

  my $callback = $args{callback} or die "requires a callback";

  my $db = db('Analysis');

  my @remove;
  while(my $row = $db->iterate(qw/id json/)) {
    my $data = decode_json($row->{json});
    my $id = $data->{id} = $row->{id};
    $callback->($data) or next;
    if (!$data->{id}) {
      push @remove, $id;
      next;
    }
    my $json = encode_json($data);
    $db->bulk_update_json($id, $json);
  }
  $db->finalize_bulk_update_json;

  $db->delete_analysis(@remove) if @remove;
}

1;

__END__

=head1 NAME

WWW::CPANTS::Process::ModifyAnalysis

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
