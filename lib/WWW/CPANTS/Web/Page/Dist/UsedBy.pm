package WWW::CPANTS::Web::Page::Dist::UsedBy;

use WWW::CPANTS;
use WWW::CPANTS::Web::Util;
use parent 'WWW::CPANTS::Web::Data';

sub data ($self, $path = undef, @args) {
    return unless is_path($path);

    my $db      = $self->db;
    my $dist    = page("Dist::Common")->load($path) or return;
    my @used_by = @{ decode_json($dist->{used_by} // '[]') };
    my $total   = @used_by;

    my $rows = api4('Table::ReverseDependenciesOf')->load({
        name => $dist->{name},
    });

    return {
        distribution => $dist,
        data             => { dependants => $rows->{data} },
        total_dependants => $rows->{recordsTotal},
    };
}

1;
