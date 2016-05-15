package WWW::CPANTS::Bin::Util::Timer;

use WWW::CPANTS;
use WWW::CPANTS::Util;
use Time::Duration;
use Time::HiRes qw/time/;

sub new ($class, $name) {
  log(notice => "$name started");
  bless { start => time, name => $name, pid => $$ }, $class;
}

sub show_progress ($self, $done, $total) {
  return unless $done;
  my $elapsed = time - $self->{start};
  my $estimate = $elapsed * $total / $done;
  my $per_sec = $elapsed ? $done / $elapsed : '-';
  log(info => "done %d/%d (%0.2f/s; estimated end time: %s)", $done, $total, $per_sec, strftime("%Y-%m-%d %H:%M", $estimate + $self->{start}));
}

sub DESTROY ($self) {
  return if $self->{pid} ne $$;
  local $Time::Duration::MILLISECOND = 1;
  my $elapsed = duration(time - $self->{start});
  log(notice => $self->{name}." ended (elapsed $elapsed)");
}

1;
