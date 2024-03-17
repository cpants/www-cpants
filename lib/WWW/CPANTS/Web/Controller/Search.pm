package WWW::CPANTS::Web::Controller::Search;

use Mojo::Base 'WWW::CPANTS::Web::Controller', -signatures;
use experimental qw/switch/;
no warnings qw/deprecated/;

sub search ($c) {
    $c->render_with(
        sub ($c, $params, $format) {
            my $name = $params->{name};
            my $res;
            if (defined $name and $name ne '') {
                $res = $c->get_api('Search', $params) or return;
                if (@{ $res->{authors} } == 1 && !@{ $res->{dists} }) {
                    return { redirect_to => '/author/' . $res->{authors}[0] };
                }
                if (@{ $res->{dists} } == 1 && !@{ $res->{authors} }) {
                    return { redirect_to => '/dist/' . $res->{dists}[0] };
                }
            }

            given ($format) {
                when ('') {
                    return $res if $res->{redirect_to};
                    return {
                        render => 'search',
                        stash  => $res,
                    };
                }
            }
            return;
        },
    );
}

1;
