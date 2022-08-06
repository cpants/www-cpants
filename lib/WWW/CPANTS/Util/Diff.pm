package WWW::CPANTS::Util::Diff;

use Mojo::Base -strict, -signatures;
use Exporter qw/import/;

our @EXPORT    = qw/diff/;
our @EXPORT_OK = qw/kwalitee_diff/;

if (eval { require Text::Diff::Unified::XS; 1 }) {
    *diff = \&_xs_diff;
} else {
    require Text::Diff;
    *diff = \&_pp_diff;
}

sub _xs_diff ($old, $new) {
    Text::Diff::Unified::XS::diff($old, $new);
}

sub _pp_diff ($old, $new) {
    Text::Diff::diff($old, $new, { STYLE => 'Unified' });
}

sub kwalitee_diff ($old, $new) {
    my @diff;
    for my $key (sort keys $new->{kwalitee}->%*) {
        my $old_value = $old->{kwalitee}{$key} // '';
        my $new_value = $new->{kwalitee}{$key} // '';
        if ($old_value ne $new_value) {
            push @diff, "$key: $old_value=>$new_value";
        }
    }
    return join ', ', @diff;
}

1;

