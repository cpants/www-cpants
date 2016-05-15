package WWW::CPANTS::Web::Page::Dist;

use WWW::CPANTS;
use WWW::CPANTS::Web::Util;
use WWW::CPANTS::Util::Kwalitee;
use parent 'WWW::CPANTS::Web::Data';

sub data ($self, $path = undef, @args) {
  return unless is_path($path);

  my $dist = page("Dist::Common")->load($path) or return;
  my $uid = $dist->{uid};

  my $db = $self->db;
  my $kwalitee = $db->table('Kwalitee')->find($uid);

  my $errors = $db->table('Errors')->select_all_errors_of($uid);
  my %errors_map = map {$_->{category} => $_->{error}} @$errors;

  my (@core_issues, @extra_issues, @experimental_issues);
  for my $indicator (@{sorted_kwalitee_indicators()}) {
    my $k = $kwalitee->{$indicator->{name}};
    next if !defined $k or $k; # pass or ignored or not checked yet
    delete $indicator->{$_} for qw/code details/; # remove code references
    if ($indicator->{is_extra}) {
      push @extra_issues, {%$indicator, error => $errors_map{$indicator->{name}}};
    } elsif ($indicator->{is_experimental}) {
      push @experimental_issues, {%$indicator, error => $errors_map{$indicator->{name}}};
    } else {
      push @core_issues, {%$indicator, error => $errors_map{$indicator->{name}}};
    }
  }

  my ($modules, $provides, $special_files);
  if (my $row = $db->table('Provides')->select_by_uid($uid)) {

    my %unauthorized = map {$_ => 1} @{decode_json($row->{unauthorized} // '[]')};
    $modules = decode_json($row->{modules} // '[]');
    $provides = decode_json($row->{provides} // '[]');
    $special_files = decode_json($row->{special_files} // '[]');
    for my $module (@$modules, @$provides) {
      $module->{unauthorized} = 1 if $unauthorized{$module->{name}};
    }
  }

  return {
    data => {
      distribution => $dist,
      modules => $modules,
      provides => $provides,
      special_files => $special_files,
      issues => {
        count => scalar(@core_issues + @extra_issues + @experimental_issues),
        core => \@core_issues,
        extra => \@extra_issues,
        experimental => \@experimental_issues,
      }
    },
  };
}

1;
