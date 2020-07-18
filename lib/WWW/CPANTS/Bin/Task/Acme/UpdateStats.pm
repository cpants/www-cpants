package WWW::CPANTS::Bin::Task::Acme::UpdateStats;

use Mojo::Base 'WWW::CPANTS::Bin::Task', -signatures;
use WWW::CPANTS::Util::Datetime;
use WWW::CPANTS::Util::Path;

our @READ  = qw/AcmeAuthors AcmeModules Uploads Whois Kwalitee/;
our @WRITE = qw/AcmeStats/;

sub run ($self, @args) {
    my $modules_table = $self->db->table('AcmeModules');
    my $authors_table = $self->db->table('AcmeAuthors');
    my $stats_table   = $self->db->table('AcmeStats');

    my $end_year = year(time);

    my $iter = $modules_table->iterate;
    while (my $row = $iter->next) {
        $self->log(info => "Updating stats for $row->{module}");

        my $module_id = $row->{module_id};
        my $authors   = $authors_table->select_authors_by_module_id($module_id);

        my $start_year = $end_year;
        if ($self->force or !$stats_table->exists({ module_id => $module_id, year => $end_year })) {
            $start_year = 2000;
        }

        for my $year (0, $start_year .. $end_year) {
            my $stats = $self->_get_yearly_stats($year, $authors);
            if (!$stats_table->exists({ module_id => $module_id, year => $year })) {
                $stats_table->insert_stats($module_id, $year, $stats);
            } else {
                $stats_table->update_stats($module_id, $year, $stats);
            }
        }
    }
}

sub _get_yearly_stats ($self, $year, $authors) {
    my %stats;
    for my $table (qw/Uploads Whois Kwalitee/) {
        $stats{$table} = $self->db->table($table)->author_stats_of_the_year($year, $authors);
    }

    return {
        active_authors        => $stats{Uploads}{active_authors}         // 0,
        new_authors           => $stats{Whois}{new_authors}              // 0,
        releases              => $stats{Uploads}{releases}               // 0,
        new_releases          => $stats{Uploads}{new_releases}           // 0,
        distributions         => $stats{Uploads}{distributions}          // 0,
        average_kwalitee      => $stats{Kwalitee}{average_kwalitee}      // 0,
        average_core_kwalitee => $stats{Kwalitee}{average_core_kwalitee} // 0,
    };
}

1;
