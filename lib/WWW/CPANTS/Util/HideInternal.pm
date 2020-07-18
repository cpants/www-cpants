package WWW::CPANTS::Util::HideInternal;

use Mojo::Base -strict, -signatures;
use Exporter qw/import/;
use WWW::CPANTS;

our @EXPORT = qw/hide_internal/;

sub hide_internal ($str) {
    my $root = WWW::CPANTS->instance->app_root;
    my ($home) = $root =~ m|^((?:[A-Z]:)?/home/[^/]+)|i;
    no warnings 'uninitialized';
    $str =~ s!$home/\.plenv/versions/[^/]+/lib/perl5/(site_perl/)?5\.\d+\.\d+/!$1lib/!g;
    $str =~ s!$home/((?:backpan|cpan)/)!$1!g;
    $str =~ s!$root/tmp/analyze/[^/]+/[^/]+/!!g;
    $str =~ s!$root/extlib/[^/]+/!!g;
    $str =~ s!$root/!!g;
    $str =~ s!$home/!!g;
    $str;
}

1;
