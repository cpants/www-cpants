package WWW::CPANTS::Model::Kwalitee;

use Role::Tiny::With;
use Mojo::Base -base, -signatures;
use WWW::CPANTS;

with qw/WWW::CPANTS::Role::Logger/;

has 'kwalitee'     => \&_build_kwalitee;
has 'names'        => \&_build_names;
has 'indicators'   => \&_build_indicators;
has 'core_metrics' => \&_build_core_metrics;
has 'metrics'      => \&_build_metrics;
has 'mapping'      => \&_build_mapping;

sub _build_kwalitee ($self) {
    WWW::CPANTS->instance->use_extlib;

    require Module::CPANTS::SiteKwalitee;

    $Module::CPANTS::Kwalitee::Files::RespectManiskip = 0;
    Module::CPANTS::SiteKwalitee->new;
}

sub _build_indicators ($self) {
    my @indicators;
    for my $i ($self->kwalitee->get_indicators->@*) {
        next if $i->{is_disabled};
        push @indicators, $i;
    }
    \@indicators;
}

sub _build_names ($self) {
    my @names = map { $_->{name} } $self->indicators->@*;
    \@names;
}

sub _build_core_metrics ($self) {
    my @names;
    for my $i ($self->indicators->@*) {
        push @names, $i->{name} if $i->{is_core};
    }
    \@names;
}

sub _build_metrics ($self) {
    my @names;
    for my $i ($self->indicators->@*) {
        push @names, $i->{name} if $i->{is_core} or $i->{is_extra};
    }
    \@names;
}

sub _build_mapping ($self) {
    $self->kwalitee->get_indicators_hash;
}

sub indicator ($self, $name) {
    $self->mapping->{$name};
}

sub indicator_setting ($self, $name) {
    my $indicator = $self->mapping->{$name} or return;
    my %setting;
    for my $key (keys %$indicator) {
        my $value = $indicator->{$key};
        next if ref $value eq ref sub { };
        $setting{$key} = $value;
    }
    \%setting;
}

sub core_total ($self) {
    scalar $self->core_metrics->@*;
}

sub total ($self) {
    scalar $self->metrics->@*;
}

sub is_valid_name ($self, $name) {
    return unless $name;
    return unless exists $self->mapping->{$name};
    return $name;
}

sub modules ($self) { $self->kwalitee->generators }

sub failing_core_metrics ($self, $kwalitee = {}) {
    my @fails = grep { defined $kwalitee->{$_} && !$kwalitee->{$_} } $self->core_metrics->@*;
    \@fails;
}

sub score ($self, $kwalitee, $is_core = 0) {
    my $score = 0;
    my $names = $is_core ? $self->core_metrics : $self->metrics;
    my $total = $self->core_total;
    for my $name (@$names) {
        next unless defined $kwalitee->{$name};
        if ($kwalitee->{$name} < 0) {
            $total--;
            next;
        }
        $score += $kwalitee->{$name};
    }
    return unless $score;

    sprintf "%.2f", ($score * 100 / $total);
}

sub set_results ($self, $stash) {
    my %kwalitee;
    my $x_ignore = _x_ignore($stash);
    for my $indicator ($self->indicators->@*) {
        next if $indicator->{needs_db};
        my $name = $indicator->{name};
        my $ret;
        {
            my @warnings;
            local $SIG{__WARN__} = sub (@args) { push @warnings, @args };
            $ret = $indicator->{code}($stash, $indicator);
            if (@warnings) {
                $stash->{error}{cpants_warnings} = "$name: " . join '', @warnings;
            }
        }
        $ret = ($ret && $ret > 0) ? 1 : $ret // 0;    # normalize

        if ($x_ignore && $x_ignore->{$name} && $indicator->{ignorable} && !$ret) {
            $ret = -1;
            if (my $error = $stash->{error}{$name}) {
                $stash->{error}{$name} = "$error [ignored]";
            }
            my $path = $stash->{path};
            $self->log(warn => "$path ignored $name via x_cpants");
        }

        $kwalitee{$name} = $ret;
    }

    $stash->{kwalitee}{$_} = $kwalitee{$_} for keys %kwalitee;
}

sub set_scores ($self, $stash) {
    my $kwalitee = $stash->{kwalitee};
    $kwalitee->{kwalitee}      = $self->score($kwalitee);
    $kwalitee->{core_kwalitee} = $self->score($kwalitee, 'core');
}

sub _x_ignore ($stash) {
    return unless exists $stash->{meta_yml};
    my $meta = $stash->{meta_yml};

    return unless ref $meta eq 'HASH' && exists $meta->{x_cpants};
    my $x_cpants = $meta->{x_cpants};

    return unless ref $x_cpants eq 'HASH' && exists $x_cpants->{ignore};
    my $ignore = $x_cpants->{ignore};

    if (ref $ignore ne 'HASH') {
        $stash->{error}{x_cpants} = "x_cpants ignore should be a hash reference (key: metric, value: reason to ignore)";
        return;
    }
    $ignore;
}

1;
