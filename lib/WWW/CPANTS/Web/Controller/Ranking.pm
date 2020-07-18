package WWW::CPANTS::Web::Controller::Ranking;

use Mojo::Base 'WWW::CPANTS::Web::Controller', -signatures;
use experimental qw/switch/;
use String::CamelCase qw/decamelize/;

sub index ($c) {
    $c->render_with(
        sub ($c, $params, $format) {

            my $tab    = $params->{tab} // 'FiveOrMore';
            my $league = $params->{league} = decamelize($tab);
            my $data   = $c->get_api('Ranking', $params) or return;

            given ($format) {
                when ('json') {
                    return { json => $data };
                }
                when ('') {
                    return {
                        render => "ranking/$league",
                        stash  => {
                            league  => $league,
                            ranking => $data,
                        },
                    };
                }
            }
        },
    );
}

1;
