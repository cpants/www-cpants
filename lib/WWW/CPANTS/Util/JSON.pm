package WWW::CPANTS::Util::JSON;

use strict;
use warnings;
use JSON::XS ();
use Exporter::Lite;
use WWW::CPANTS::AppRoot;

our @EXPORT = qw/
  slurp_json save_json json_file
  encode_json decode_json encode_pretty_json
/;

my $parser = JSON::XS->new->utf8->canonical->convert_blessed(1);

sub decode_json ($) { $parser->decode(@_) }
sub encode_json ($) { $parser->encode(@_) }
sub encode_pretty_json ($) { $parser->pretty->encode(@_) }

sub json_file {
  my $file = shift;
  file($file =~ /\.json$/ ? $file : 'tmp/data/'.$file.'.json');
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

# to convert version objects in the stash
# XXX: of course it's best not to use these costly conversions

{
  no warnings 'redefine';
  sub version::TO_JSON { "$_[0]" }
  sub Module::Build::Version::TO_JSON { "$_[0]" }
}

1;

__END__

=head1 NAME

WWW::CPANTS::Util::JSON

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 METHODS

=head2 json_file
=head2 slurp, slurp_json
=head2 save, save_json
=head2 decode_json, encode_json, encode_pretty_json

=head1 AUTHOR

Kenichi Ishigaki, E<lt>ishigaki@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 by Kenichi Ishigaki.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
