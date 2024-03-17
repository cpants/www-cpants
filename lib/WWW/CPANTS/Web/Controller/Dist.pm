package WWW::CPANTS::Web::Controller::Dist;

use Mojo::Base 'WWW::CPANTS::Web::Controller', -signatures;
use WWW::CPANTS::Web::Util::Badge;
use experimental qw/switch/;
use Syntax::Keyword::Try;

sub index ($c) {
    $c->render_with(
        sub ($c, $params, $format) {
            my $tab       = $params->{tab} // 'Overview';
            my $tab_class = $c->tab_class("Dist", $tab);
            my $data      = $c->get_api($tab_class, $params) or return;

            my $distribution = $c->get_api("Dist::Common", $params) or return;
            return unless $distribution->{name};

            $data->{distribution} = $distribution;

            given ($format) {
                when ('json') {
                    return { json => $data };
                }
                when (/\A(?:png|svg)\z/) {
                    if ($tab eq 'Overview') {
                        my $path;
                        try {
                            $path = badge($distribution->{core_kwalitee}, $format);
                        } catch {
                            my $error = $@;
                            WWW::CPANTS->instance->logger->log(error => $error);
                        }
                        return { static => $path, mtime => $distribution->{last_analyzed_at} };
                    }
                }
                when ('') {
                    return {
                        render => $c->template_name($tab_class),
                        stash  => $data,
                    };
                }
            }
            return;
        },
    );
}

1;
