package WWW::CPANTS::DB::Table::AcmeStats;

use Mojo::Base 'WWW::CPANTS::DB::Table', -signatures;

sub columns ($self) { (
    [module_id             => '_acme_id_'],
    [year                  => '_year_'],
    [new_authors           => 'integer', default => 0],
    [active_authors        => 'integer', default => 0],
    [releases              => 'integer', default => 0],
    [new_releases          => 'integer', default => 0],
    [distributions         => 'integer', default => 0],
    [average_kwalitee      => 'float',   default => 0],
    [average_core_kwalitee => 'float',   default => 0],
) }

sub indices ($self) { (
    { unique => 1, columns => [qw/module_id year/] },
) }

sub insert_stats ($self, $module_id, $year, $stats) {
    my $sql = <<~';';
    INSERT INTO acme_stats (module_id, year, new_authors, active_authors, releases, new_releases, distributions, average_kwalitee, average_core_kwalitee)
    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
    ;
    $self->insert($sql, $module_id, $year, @$stats{qw/new_authors active_authors releases new_releases distributions average_kwalitee average_core_kwalitee/});
}

sub update_stats ($self, $module_id, $year, $stats) {
    my $sql = <<~';';
    UPDATE acme_stats
    SET new_authors = ?, active_authors = ?, releases = ?, new_releases = ?, distributions = ?, average_kwalitee = ?, average_core_kwalitee = ?
    WHERE module_id = ? AND year = ?
    ;
    $self->update($sql, @$stats{qw/new_authors active_authors releases new_releases distributions average_kwalitee average_core_kwalitee/}, $module_id, $year);
}

sub select_latest_stats ($self) {
    my $sql = <<~';';
    SELECT module_id, active_authors, releases, new_releases, distributions, average_kwalitee, average_core_kwalitee
    FROM acme_stats
    GROUP BY module_id HAVING year = 0
    ;
    $self->select_all($sql);
}

sub select_active_authors_by_module_id ($self, $module_id) {
    my $sql = <<~';';
    SELECT year, active_authors
    FROM acme_stats
    WHERE module_id = ? AND year != 0
    ORDER BY year DESC
    ;
    $self->select_all($sql, $module_id);
}

sub select_new_authors_by_module_id ($self, $module_id) {
    my $sql = <<~';';
    SELECT year, new_authors
    FROM acme_stats
    WHERE module_id = ? AND year != 0
    ORDER BY year DESC
    ;
    $self->select_all($sql, $module_id);
}

sub select_new_releases_by_module_id ($self, $module_id) {
    my $sql = <<~';';
    SELECT year, new_releases
    FROM acme_stats
    WHERE module_id = ? AND year != 0
    ORDER BY year DESC
    ;
    $self->select_all($sql, $module_id);
}

sub select_releases_by_module_id ($self, $module_id) {
    my $sql = <<~';';
    SELECT year, releases
    FROM acme_stats
    WHERE module_id = ? AND year != 0
    ORDER BY year DESC
    ;
    $self->select_all($sql, $module_id);
}

1;
