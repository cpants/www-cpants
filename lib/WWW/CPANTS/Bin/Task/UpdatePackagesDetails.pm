package WWW::CPANTS::Bin::Task::UpdatePackagesDetails;

use WWW::CPANTS;
use WWW::CPANTS::Bin::Util;
use parent 'WWW::CPANTS::Bin::Task';

sub run ($self, @args) {
  my $cpan = $self->cpan;
  my $db = $self->db;
  $db->advisory_lock(qw/PackagesDetails/) or return;

  $cpan->fetch_packages_details unless $cpan->has_packages_details;

  my $table = $db->table('PackagesDetails');

  log(info => "updating packages.details");

  try {
    my $txn = $table->txn;
    $table->truncate;
    $table->bulk_insert($cpan->list_packages_details);
    $txn->commit;
  }
  catch {
    my $error = $@;
    log(error => $@);
  }

  log(info => "updated packages.details");
}

1;
