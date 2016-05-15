package WWW::CPANTS::Web::API::V4::Table::Ranking;

use WWW::CPANTS;
use WWW::CPANTS::Web::Util;
use parent 'WWW::CPANTS::Web::Data';

my %Methods = (
  five_or_more => {
    select => 'select_ranking_five_or_more',
    count => 'count_authors_with_five_or_more_distributions',
  },
  less_than_five => {
    select => 'select_ranking_less_than_five',
    count => 'count_authors_with_less_than_five_distributions',
  },
);

sub load ($self, $params = {}) {
  my $league = $params->{league} // '';
  my $method = $Methods{$league} or return $self->error;
  my $select_method = $method->{select};
  my $count_method = $method->{count};

  my $length = is_int($params->{length}) // 50;
  my $start  = is_int($params->{start}) // 0;

  my $db = $self->db;
  my $table = $db->table('Authors');
  my $ranking = $table->$select_method($length, $start);
  my $total = $table->$count_method();

  my @rows;
  for my $author (@$ranking) {
    $author->{$_} = html($author->{$_}) for keys %$author;
    push @rows, $author;
  }
  return {
    recordsTotal => $total,
    data => \@rows,
  };
}

1;
