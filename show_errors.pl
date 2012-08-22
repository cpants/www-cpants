use strict;
use warnings;
use lib "lib";

WWW::CPANTS::Script::ShowError->run_directly;

package WWW::CPANTS::Script::ShowError;
use base 'WWW::CPANTS::Script::Base';
use WWW::CPANTS::DB::Analysis;
use JSON::XS;

sub _run {
  my ($self, @args) = @_;

  my $db = WWW::CPANTS::DB::Analysis->new;
  if (@args) {
    while(my $json = $db->fetch_json_by_id($_)) {
      my $data = decode_json($json);
      if ($data->{error} && $data->{error}{cpants}) {
        print "$_: $data->{error}{cpants}\n";
      }
    }
  }
  else {
    my %errors;
    while(my $row = $db->fetch_row) {
      my $data = decode_json($row->{json});
#      next if !$data->{size_packed};
      if ($data->{error} && $data->{error}{cpants}) {
#        $errors{$row->{path}} = $data->{size_packed};
        print "$row->{path} ($row->{id}): $data->{error}{cpants}\n";
      }
    }
#    print "$_: $errors{$_}\n" for sort { $errors{$a} <=> $errors{$b}} keys %errors;
  }
}
