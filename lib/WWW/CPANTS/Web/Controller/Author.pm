package WWW::CPANTS::Web::Controller::Author;

use Mojo::Base 'WWW::CPANTS::Web::Controller', -signatures;
use WWW::CPANTS::Web::Util::Badge;
use experimental qw/switch/;
use Syntax::Keyword::Try;
use XML::Atom::SimpleFeed;

sub index ($c) {
    $c->render_with(
        sub ($c, $params, $format) {
            my $author = $c->get_api('Author', $params) or return;
            return unless $author->{name};

            my $data;
            if ($author->{deleted} or $author->{banned}) {
                $data = { author => $author };
            } else {
                my $recent_releases = $c->get_api('Author::RecentReleases', $params);

                my $cpan_distributions = $c->get_api('Author::CPANDistributions', $params);

                $data = {
                    total_recent_releases    => $recent_releases->{recordsTotal},
                    total_cpan_distributions => $cpan_distributions->{recordsTotal},
                    author                   => $author,
                    data                     => {
                        recent_releases    => $recent_releases->{data},
                        cpan_distributions => $cpan_distributions->{data},
                    },
                };
            }

            given ($format) {
                when ('json') {
                    return { json => $data };
                }
                when (/\A(?:png|svg)\z/) {
                    my $path;
                    try {
                        $path = badge($data->{author}{average_core_kwalitee}, $format);
                    } catch {
                        my $error = $@;
                        WWW::CPANTS->instance->logger->log(error => $error);
                    }
                    return { static => $path, mtime => $author->{last_analyzed_at} };
                }
                when ('') {
                    $data->{body_class} = "pause-" . (lc $params->{pause_id});
                    return { render => 'author', stash => $data };
                }
            }
            return;
        },
    );
}

sub feed ($c) {
    $c->render_with(
        sub ($c, $params, $format) {
            my $data = $c->get_api('Author::Feed', $params) or return;

            given ($format) {
                when ('') {
                    my $pause_id = $params->{pause_id};
                    my $base     = $c->app->ctx->base_url;
                    my $link     = "$base/author/$pause_id/feed";
                    my $feed     = XML::Atom::SimpleFeed->new(
                        -encoding => 'utf-8',
                        id        => $link,
                        link      => $link,
                        $data->{feed}->%*,
                    );
                    for my $entry ($data->{entries}->@*) {
                        $feed->add_entry(%$entry);
                    }
                    return { render => { format => 'atom', text => $feed->as_string } };
                }
            }
            return;
        },
    );
}

1;
