package WWW::CPANTS::Web::Controller::Kwalitee;

use Mojo::Base 'WWW::CPANTS::Web::Controller', -signatures;
use experimental qw/switch/;

sub index ($c) {
    $c->render_with(
        sub ($c, $params, $format) {
            my $res = $c->get_api('Kwalitee') or return;

            given ($format) {
                when ('json') {
                    return { json => $res };
                }
                when ('') {
                    return {
                        render => 'kwalitee',
                        stash  => $res,
                    };
                }
            }
            return;
        },
    );
}

sub indicator ($c) {
    $c->render_with(
        sub ($c, $params, $format) {
            my $tab       = $params->{tab} // 'Indicator';
            my $tab_class = $c->tab_class("Kwalitee", $tab);
            my $res       = $c->get_api($tab_class, $params) or return;

            given ($format) {
                when ('json') {
                    return { json => $res };
                }
                when ('') {
                    return {
                        render => $c->template_name($tab_class),
                        stash  => $res,
                    };
                }
            }
        },
    );
}

1;
