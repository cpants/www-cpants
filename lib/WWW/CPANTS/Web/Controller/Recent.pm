package WWW::CPANTS::Web::Controller::Recent;

use Mojo::Base 'WWW::CPANTS::Web::Controller', -signatures;
use experimental qw/switch/;

sub index ($c) {
    $c->render_with(
        sub ($c, $params, $format) {
            my $res = $c->get_api('Recent', $params) or return;

            given ($format) {
                when ('json') {
                    return { json => $res };
                }
                when ('') {
                    return {
                        render => 'recent',
                        stash  => $res,
                    };
                }
            }
            return;
        },
    );
}

1;
