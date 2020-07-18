package WWW::CPANTS::Bin::Task::Enqueue;

use WWW::CPANTS;
use WWW::CPANTS::Bin::Util;
use parent 'WWW::CPANTS::Bin::Task';

sub run ($self, @args) {
    my $db    = $self->db;
    my $queue = $db->table('Queue');

    my $bulk = $queue->bulk_insert(undef, { ignore => 1 });

    if (@args) {
        $db->advisory_lock(qw/Queue/) or return;
        for my $path (@args) {
            next unless defined $path and $path ne '';
            $bulk->insert([{
                uid        => path_uid($path),
                path       => $path,
                created_at => time,
                priority   => 100,
            }]);
        }
        @ARGV = ();
    } else {
        $db->advisory_lock(qw/Uploads Queue/) or return;
        my $uploads         = $db->table('Uploads');
        my $cpants_revision = WWW::CPANTS->context->cpants_revision();
        my $iter            = $uploads->iterate_rows_with_older_revision($cpants_revision);
        while (my $row = $iter->next) {
            my $priority = !$row->{cpants_revision} ? 10 : 0;
            $priority += 5 if $row->{cpan};
            $priority += $cpants_revision - $row->{cpants_revision};
            $bulk->insert([{
                uid        => $row->{uid},
                path       => $row->{path},
                created_at => time,
                priority   => $priority,
            }]);
        }
    }
    $bulk->finalize;
}

1;
