package WWW::CPANTS::Web::Controller::Release;

use Mojo::Base 'WWW::CPANTS::Web::Controller', -signatures;
use WWW::CPANTS::Web::Util::Badge;
use experimental qw/switch/;
use Syntax::Keyword::Try;

sub index ($c) {
    $c->render_with(
        sub ($c, $params, $format) {
            my $tab       = $params->{tab} // 'Overview';
            my $tab_class = $c->tab_class("Release", $tab);
            my $data      = $c->get_api($tab_class, $params) or return;

            $data->{distribution} = $c->get_api("Release::Common", $params) or return;

            given ($format) {
                when ('json') {
                    return { json => $data->{data} };
                }
                when (/\A(?:png|svg)\z/) {
                    if ($tab eq 'Overview') {
                        my $path;
                        try {
                            $path = badge($data->{distribution}{core_kwalitee}, $format);
                        } catch {
                            my $error = $@;
                            $c->app->log(error => $error);
                        }
                        return { static => $path };
                    }
                }
                when ('') {
                    ## Dist::* and Release::* share the same templates
                    my $template_class = $tab_class =~ s/Release::/Dist::/r;
                    return {
                        render => $c->template_name($template_class),
                        stash  => $data,
                    };
                }
            }
            return;
        },
    );
}

1;
