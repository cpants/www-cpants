package WWW::CPANTS::Web::Page::Kwalitee;

use WWW::CPANTS;
use WWW::CPANTS::Util;
use WWW::CPANTS::Util::Kwalitee;
use parent 'WWW::CPANTS::Web::Data';

sub data ($self, @args) {
  my $fails = $self->db->table('Kwalitee')->count_fails;

  my $indicators = kwalitee_indicators();

  my %metrics;
  for my $indicator (@$indicators) {
    my $level =
      $indicator->{is_experimental} ? 'experimental' :
      $indicator->{is_extra} ? 'extra' : 'core';
    my $name = $indicator->{name};
    push @{$metrics{$level} //= []}, {
      name => $name,
      description => $indicator->{error},
      remedy => $indicator->{remedy},
      defined_in => $indicator->{defined_in},
      latest_fails => $fails->{"latest_$name"},
      cpan_fails => $fails->{"cpan_$name"},
      backpan_fails => $fails->{"backpan_$name"},
      latest_fail_rate => percent($fails->{"latest_$name"}, $fails->{latest_total}),
      cpan_fail_rate => percent($fails->{"cpan_$name"}, $fails->{cpan_total}),
      backpan_fail_rate => percent($fails->{"backpan_$name"}, $fails->{backpan_total}),
    };
  }

  return {
    data => {
      core_indicators => $metrics{core},
      extra_indicators => $metrics{extra},
      experimental_indicators => $metrics{experimental},
    },
  }
}

1;
