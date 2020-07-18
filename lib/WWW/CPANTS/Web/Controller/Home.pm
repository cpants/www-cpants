package WWW::CPANTS::Web::Controller::Home;

use Mojo::Base 'WWW::CPANTS::Web::Controller', -signatures;
use experimental qw/switch/;

sub index ($c) {
    $c->render_with(
        sub ($c, $params, $format) {
            my $res = $c->get_api('Recent') or return;

            given ($format) {
                when ('') {
                    return {
                        render => 'home',
                        stash  => {
                            releases => $res->{data},
                        },
                    };
                }
            }
            return;
        },
    );
}

1;
