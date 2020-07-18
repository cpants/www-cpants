package WWW::CPANTS::Model::Timer;

use Role::Tiny::With;
use Mojo::Base -base, -signatures;
use Time::Duration qw/duration/;
use Time::HiRes qw/time/;
use WWW::CPANTS::Util::Datetime qw/strftime/;

with qw/WWW::CPANTS::Role::Logger/;

has 'name' => 'Timer';
has 'total';
has 'started_at';
has 'pid';

sub start ($self) {
    my $name = $self->name;
    return if $name =~ /^Maint::/;

    $self->started_at(time);
    $self->pid($$);
    $self->log(notice => "[$name] started [$$]");
}

sub show_progress ($self, $done) {
    return unless $done;
    return unless $self->started_at;

    my $name    = $self->name;
    my $elapsed = time - $self->started_at;
    if (my $total = $self->total) {
        my $estimate = sprintf "(%0.2f/s; estimated end time: %s) ",
            ($elapsed ? $done / $elapsed : '-'),
            strftime("%Y-%m-%d %H:%M", $elapsed * $total / $done + $self->started_at);
        $self->log(info => "[$name] $done/$total $estimate [$$]");
    } else {
        $self->log(info => "[$name] $done [$$]");
    }
}

sub DESTROY ($self) {
    return unless $self->started_at and $self->pid eq $$;
    local $Time::Duration::MILLISECOND = 1;
    my $duration = duration(time - $self->started_at);
    my $name     = $self->name;
    $self->log(notice => "[$name] ended (elapsed $duration) [$$]");
}

1;
