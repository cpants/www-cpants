package WWW::CPANTS::Bin::Task::RegisterNew;

use Mojo::Base 'WWW::CPANTS::Bin::Task', -signatures;
use WWW::CPANTS::Util::Datetime;
use WWW::CPANTS::Util::Distname;
use WWW::CPANTS::Util::Version;

our @READ  = qw/Uploads/;
our @WRITE = qw/Uploads Kwalitee Analysis Provides RequiresAndUses Resources/;

sub run ($self, @args) {
    return unless @args;

    my @dists;
    for my $path (@args) {
        my $dist = valid_distinfo($path) or next;
        push @dists, $dist;
    }
    $self->register_if_new(\@dists);
}

sub register_if_new ($self, $dists) {
    my @new;
    for my $dist (@$dists) {
        next if $self->db->table('Uploads')->exists({ uid => $dist->{uid} });

        my $version_number = numify_version($dist->{version});
        if (!defined $version_number) {
            $self->log(debug => "$dist->{path} has a non-numerical dist version ($dist->{version})");
            $version_number = numify_version($dist->{version} =~ s/[^v0-9.]//gr);
        }
        my $size = -s $dist->{filename};

        push @new, {
            uid            => $dist->{uid},
            path           => $dist->{path},
            author         => $dist->{author},
            name           => $dist->{name},
            version        => $dist->{version},
            version_number => $version_number,
            released       => $dist->{released},
            year           => year($dist->{released}),
            cpan           => $dist->{cpan}   // 0,
            stable         => $dist->{stable} // 1,
            size           => $size,
        };
    }

    return unless @new;

    my @uids = map { +{ uid => $_->{uid} } } @new;

    my $db = $self->db;
    for my $table (qw/Uploads Kwalitee Analysis/) {
        $db->table($table)->bulk_insert(\@new);
    }
    for my $table (qw/Provides RequiresAndUses Resources/) {
        $db->table($table)->bulk_insert(\@uids, { ignore => 1 });
    }
    scalar @new;
}

1;
