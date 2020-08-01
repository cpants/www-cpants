package WWW::CPANTS::DB::Table::Whois;

use Mojo::Base 'WWW::CPANTS::DB::Table', -signatures;

sub columns ($self) { (
    [pause_id    => '_pause_id_',   primary       => 1],
    [name        => 'varchar(255)', character_set => 'utf8mb4'],
    [ascii_name  => 'varchar(255)'],
    [email       => 'varchar(255)'],
    [homepage    => 'varchar(255)'],
    [has_cpandir => '_bool_', default => 0],
    [introduced  => '_epoch_'],
    [year        => '_year_'],
    [nologin     => '_bool_', default => 0],
    [deleted     => '_bool_', default => 0],
    [system      => '_bool_', default => 0],
) }

sub select_all_by_pause_ids ($self, $pause_ids) {
    my $sql = <<~";";
    SELECT * FROM whois WHERE pause_id IN (:pause_ids)
    ;
    $self->select_all($sql, [pause_ids => $pause_ids]);
}

sub author_stats_of_the_year ($self, $year, $pause_ids) {
    my $cond = $year ? '=' : '!=';
    my $sql  = <<~";";
    SELECT COUNT(*) AS new_authors FROM whois
    WHERE year $cond ? AND pause_id IN (:pause_ids)
    ;
    $self->select($sql, $year, [pause_ids => $pause_ids]);
}

1;
