package WWW::CPANTS::Web;

use Mojo::Base 'Mojolicious', -signatures;
use Digest::MD5 qw/md5_hex/;
use WWW::CPANTS::Util::Path;

our $VERSION = '0.05';

has 'ctx' => \&_build_ctx;

sub startup ($app) {
    if ($ENV{CPANTS_WEB_DEBUG} or $^O eq 'MSWin32') {
        $app->mode('development');
        $app->log->level('debug');
    } else {
        $app->mode('production');
        $app->log->level('error');
    }
    $app->secrets([md5_hex($$ . time)]);

    if (WWW::CPANTS->is_testing) {
        push $app->static->paths->@*, cpants_path('public');
    }

    my $r = $app->routes->under('/')->to('root#check_maintenance');
    $r->get('/')->to('home#index');
    $r->get('/author/:pause_id')->to('author#index');
    $r->get('/author/<#pause_id>.json')->to('author#index', { format => 'json' });
    $r->get('/author/<#pause_id>.png')->to('author#index', { format => 'png' });
    $r->get('/author/<#pause_id>.svg')->to('author#index', { format => 'svg' });
    $r->get('/author/:pause_id/feed')->to('author#feed');
    $r->get('/dist/<#name>.json')->to('dist#index', { format => 'json' });
    $r->get('/dist/<#name>.png')->to('dist#index', { format => 'png' });
    $r->get('/dist/<#name>.svg')->to('dist#index', { format => 'svg' });
    $r->get('/dist/#name')->to('dist#index');
    $r->get('/dist/#name/:tab')->to('dist#index');
    $r->get('/dist/#name/<#tab>.json')->to('dist#index');
    $r->get('/release/:pause_id/<#name>.json')->to('release#index', { format => 'json' });
    $r->get('/release/:pause_id/<#name>.png')->to('release#index', { format => 'png' });
    $r->get('/release/:pause_id/<#name>.svg')->to('release#index', { format => 'svg' });
    $r->get('/release/:pause_id/#name')->to('release#index');
    $r->get('/release/:pause_id/#name/:tab')->to('release#index');
    $r->get('/release/:pause_id/#name/<#tab>.json')->to('release#index');
    $r->get('/ranking')->to('ranking#index');
    $r->get('/ranking/:tab')->to('ranking#index');
    $r->get('/kwalitee')->to('kwalitee#index');
    $r->get('/kwalitee/:name')->to('kwalitee#indicator');
    $r->get('/kwalitee/:name/:tab')->to('kwalitee#indicator');
    $r->get('/stats')->to('stats#index');
    $r->get('/stats/:tab')->to('stats#tab');
    $r->get('/recent')->to('recent#index');
    $r->get('/search')->to('search#search');
    $r->post('/search')->to('search#search');
    $r->get('/about')->to('about#index');
    $r->get('/about/:tab')->to('about#tab');

    $app->plugin('WWW::CPANTS::Web::Plugin::Helpers');
    $app->plugin('WWW::CPANTS::Web::Plugin::Hooks');
}

sub _build_ctx ($self) {
    require WWW::CPANTS::Web::Context;
    WWW::CPANTS::Web::Context->new;
}

1;

__END__

=encoding utf-8

=head1 NAME

WWW::CPANTS::Web - CPANTS web frontend

=head1 SYNOPSIS

    use WWW::CPANTS::Web;

=head1 DESCRIPTION

=head1 METHODS

=head1 AUTHOR

Kenichi Ishigaki, E<lt>ishigaki@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2019 by Kenichi Ishigaki.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
