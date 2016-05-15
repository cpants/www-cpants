package WWW::CPANTS::Web::Page::Author;

use WWW::CPANTS;
use WWW::CPANTS::Web::Util;
use parent 'WWW::CPANTS::Web::Data';

sub data ($self, $pause_id = undef, @args) {
  return unless is_pause_id($pause_id);

  my $db = $self->db;
  my $author = $db->table('Authors')->find($pause_id) or return;
  my $whois = $author->{whois} ? decode_json(delete $author->{whois}) : {};

  $author->{$_} = $whois->{$_} for keys %$whois;

  my $recent_releases = api4('Table::RecentBy')->load({pause_id => $pause_id});

  my $cpan_distributions = api4('Table::CPANDistributionsBy')->load({pause_id => $pause_id});

  return {
    total_recent_releases => $recent_releases->{recordsTotal},
    total_cpan_distributions => $cpan_distributions->{recordsTotal},
    author => $author,
    data => {
      recent_releases => $recent_releases->{data},
      cpan_distributions => $cpan_distributions->{data},
    },
  };
}

1;
