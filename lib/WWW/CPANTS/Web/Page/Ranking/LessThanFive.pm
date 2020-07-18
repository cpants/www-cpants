package WWW::CPANTS::Web::Page::Ranking::LessThanFive;

use WWW::CPANTS;
use WWW::CPANTS::Web::Util;
use parent 'WWW::CPANTS::Web::Data';

sub data ($self, @args) {
    my $ranking = api4('Table::Ranking')->load({
        league => 'less_than_five',
    });

    return {
        data => {
            ranking => $ranking->{data},
            total   => $ranking->{recordsTotal},
        },
    };
}

1;
