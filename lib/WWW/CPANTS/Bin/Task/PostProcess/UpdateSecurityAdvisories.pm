package WWW::CPANTS::Bin::Task::PostProcess::UpdateSecurityAdvisories;

use Mojo::Base 'WWW::CPANTS::Bin::Task', -signatures;
use WWW::CPANTS::Util::JSON;
use CPAN::Audit;
use CPAN::Audit::DB;
use CPAN::Audit::Version;

our @READ  = qw/Distributions/;
our @WRITE = qw/Distributions/;

sub run ($self, @args) {
    return if $self->has_seen_cpan_audit_version;

    my $audit_db = CPAN::Audit::DB->db->{dists};
    unless ($audit_db) {
        $self->log(alert => "Incompatible CPAN Audit database");
        return;
    }

    my $table = $self->db->table('Distributions');
    for my $name (sort keys %$audit_db) {
        my $dist = $table->select_by_name($name);
        unless ($dist and $dist->{uids}) {
            $self->log(alert => "Distribution without uids: $name");
            next;
        }
        my $uids               = decode_json($dist->{uids});
        my @available_versions = map { $_->{version} } @$uids;

        my @warnings;
        my $advisories = $audit_db->{$name}{advisories};

        local $SIG{__WARN__} = sub { push @warnings, @_ };
        for my $advisory (@$advisories) {
            my @affected_versions = CPAN::Audit::Version->affected_versions(\@available_versions, $advisory->{affected_versions});
            $advisory->{affected_version_list} = \@affected_versions;
        }
        $table->update_advisories($name, $advisories);

        if (@warnings) {
            warn $_ for grep !/(?:Integer overflow|invalid data)/, @warnings;
        }
    }

    $self->stash->{cpan_audit_version} = $CPAN::Audit::VERSION;
}

sub has_seen_cpan_audit_version ($self) {
    my $saved = $self->stash->{cpan_audit_version} or return;

    return $saved eq $CPAN::Audit::VERSION;
}

1;
