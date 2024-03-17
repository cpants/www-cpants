package WWW::CPANTS::Web::Controller::Stats;

use Mojo::Base 'WWW::CPANTS::Web::Controller', -signatures;
use experimental qw/switch/;
no warnings qw/deprecated/;

sub index ($c) {
    $c->render_with(
        sub ($c, $params, $format) {
            my $tab       = $params->{tab} // '';
            my $tab_class = $c->tab_class("Stats", $tab);
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
