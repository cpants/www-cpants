package WWW::CPANTS::Role::Options;

use Mojo::Base -role, -signatures;

my @SeenOptions;

sub options ($self) {
    my $class = ref $self || $self;
    no strict 'refs';
    @{"$class\::OPTIONS"};
}

around 'new' => sub ($orig, $class, @args) {
    my @rules;
    for my $option ($class->options) {
        my ($rule, @attr_args) = ref $option ? @$option : ($option);
        my ($name) = $rule =~ /^(\w+)/;
        Mojo::Base::attr($class, $name, @attr_args);
        push @rules, $rule;
    }

    Mojo::Util::getopt \@ARGV, [qw/bundling pass_through/],
        \my %opts => @rules;

    push @SeenOptions, @rules;

    if (%opts) {
        if (@args == 1 and ref $args[0] eq 'HASH') {
            $args[0]{$_} = $opts{$_} for keys %opts;
        } else {
            push @args, %opts;
        }
    }
    $orig->($class, @args);
};

sub show_help ($self) {
    say "options:";
    for my $option (@SeenOptions) {
        my $name = ref $option ? $option->[0] : $option;
        $name =~ s/[\|=].+$//;
        say "  $name";
    }
}

1;
