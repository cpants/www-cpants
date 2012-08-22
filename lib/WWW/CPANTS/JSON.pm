package WWW::CPANTS::JSON;

use strict;
use warnings;
use JSON::XS;
use Exporter::Lite;
use WWW::CPANTS::AppRoot;

our @EXPORT = qw/
  slurp_json save_json json_file
  encode_json decode_json
/;

sub json_file {
  my $file = shift;
  file($file =~ /\.json$/ ? $file : 'data/'.$file.'.json');
}

sub slurp {
  my $file = json_file(shift);
  return unless $file->exists;
  my $json = $file->slurp;
  return unless defined $json;
  decode_json($json);
}

sub save {
  my $file = json_file(shift);
  $file->parent->mkdir;
  my $data = shift;
  if (defined $data) {
    $file->save(encode_json($data));
  }
  else {
    $file->remove;
  }
}

*slurp_json = \&slurp;
*save_json = \&save;

1;

__END__

=head1 NAME

WWW::CPANTS::JSON

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 METHODS

=head2 json_file
=head2 slurp, slurp_json
=head2 save, save_json

=head1 AUTHOR

Kenichi Ishigaki, E<lt>ishigaki@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 by Kenichi Ishigaki.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
