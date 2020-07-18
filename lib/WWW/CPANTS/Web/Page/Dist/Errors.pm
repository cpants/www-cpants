package WWW::CPANTS::Web::Page::Dist::Errors;

use WWW::CPANTS;
use WWW::CPANTS::Web::Util;
use parent 'WWW::CPANTS::Web::Data';

sub data ($self, $path = undef, @args) {
    return unless is_path($path);

    my $dist = page("Dist::Common")->load($path) or return;

    my $db     = $self->db;
    my $errors = $db->table('Errors')->select_all_errors_of($dist->{uid});

    return {
        distribution => $dist,
        data => { errors => $errors },
    };
}

1;
