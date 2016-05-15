package WWW::CPANTS::Util::Kwalitee;

use WWW::CPANTS;
use Exporter qw/import/;
use Module::CPANTS::SiteKwalitee;
use Const::Fast;

our @EXPORT = qw/
  kwalitee_modules
  kwalitee_indicators
  kwalitee_indicator_names
  core_kwalitee_indicator_names
  kwalitee_score
  calc_kwalitee_score
  sorted_kwalitee_indicators
  is_kwalitee_metric
/;

my $Kwalitee = Module::CPANTS::SiteKwalitee->new;
my @Indicators = grep {!$_->{is_disabled}} @{$Kwalitee->get_indicators};

const my @IndicatorNames => map {$_->{name}} @Indicators;
const my @CoreIndicatorNames => map {$_->{name}} grep {!$_->{is_extra} && !$_->{is_experimental}} @Indicators;

const my %Level => (
  experimental => 2,
  extra => 1,
  core => 0,
);

const my %IndicatorLevel => map {
  $_->{name} => (
    $_->{is_experimental} ? $Level{experimental} :
    $_->{is_extra} ? $Level{extra} :
    $Level{core}
  )
} @Indicators;

my @SortedIndicators = sort {
  $IndicatorLevel{$a->{name}} <=> $IndicatorLevel{$b->{name}} or
  $a->{name} cmp $b->{name}
} @Indicators;

sub is_kwalitee_metric ($name) {
  return unless defined $name;
  return unless $name =~ /\A[a-z_]+\z/;
  exists $IndicatorLevel{$name} ? $name : undef;
}

sub kwalitee_modules () { $Kwalitee->generators }

sub kwalitee_indicators () { \@Indicators }

sub sorted_kwalitee_indicators () { \@SortedIndicators }

sub kwalitee_indicator_names () { \@IndicatorNames }
sub core_kwalitee_indicator_names () { \@CoreIndicatorNames }

sub calc_kwalitee_score ($results = {}, $level_name = 'extra') {
  my $core_total = 0;
  my $score = 0;
  my $max_level = $Level{$level_name} // 0;
  for my $name (keys %$results) {
    next if !exists $IndicatorLevel{$name};
    next if $IndicatorLevel{$name} > $max_level;
    next if $results->{$name} < 0;
    $score += $results->{$name};
    next if $IndicatorLevel{$name} > $Level{core};
    $core_total++;
  }

  kwalitee_score($score * 100 / $core_total);
}

sub kwalitee_score ($score) { $score ? sprintf("%.2f", $score) : '-' }

1;
