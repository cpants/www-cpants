package WWW::CPANTS::Bin::Task::UpdateWhois;

use WWW::CPANTS;
use WWW::CPANTS::Bin::Util;
use parent 'WWW::CPANTS::Bin::Task';

sub run ($self, @args) {
  my $cpan = $self->cpan;
  my $db = $self->db;
  $db->advisory_lock(qw/Authors/) or return;

  $cpan->fetch_whois unless $cpan->has_whois;

  my $table = $db->table('Authors');

  log(info => "updating whois");

  my %whois = map {$_->{pause_id} => $_->{whois}} @{$table->select_all_pause_id_and_whois // []};

  my (@new, @updates);
  for my $author (@{$cpan->list_whois}) {
    my $pause_id = $author->{pause_id};
    if (!exists $whois{$pause_id}) {
      push @new, {
        pause_id => $pause_id,
        introduced => $author->{introduced},
        has_cpandir => $author->{has_cpandir},
        whois => encode_json($author),
      };
    } elsif (diff_json($whois{$pause_id}, $author)) {
      push @updates, {
        pause_id => $pause_id,
        introduced => $author->{introduced},
        has_cpandir => $author->{has_cpandir},
        whois => encode_json($author),
      };
    }
  }
  if (@new) {
    $table->bulk_insert(\@new);
  }
  if (@updates) {
    $table->update_whois(@$_{qw/pause_id introduced has_cpandir whois/}) for @updates;
  }

  log(info => "updated whois");
}

1;
