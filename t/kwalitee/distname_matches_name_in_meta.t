use Mojo::Base -strict, -signatures;
use WWW::CPANTS::Test;

test_kwalitee(
    'distname_matches_name_in_meta',
    # .pm
    ['LEEJO/CGI.pm-4.02.tar.gz', 0],

    # name with ::
    ['VLADO/CGI-AuthRegister-1.0.tar.gz',           0],
    ['BARBIE/CPAN-Testers-WWW-Reports-3.48.tar.gz', 0],

    # two dashes
    ['JESUS/Net--RabbitMQ-0.2.7.tar.gz', 0],

    # lacks name field in META
    ['DRSTEVE/stylehouse-20140427.tar.gz', 0],

    # name not to have been updated after rename (or copy)
    ['INA/Char/Latin1/Char-Latin1-0.96.tar.gz',                 0],
    ['SADAMS/Mojolicious-Command-generate-upstart-0.02.tar.gz', 0],

    # distributed with the basename only
    ['JRUBIN/FT817COMM-0.9.9.tar.gz', 0],

    # with a prefix such as p5- and perl-
    ['SHMORIMO/p5-Text-Xslate-Syntax-Any-1.5015.tar.gz', 0],
    ['LOTTC/perl-OSDial-2.2.9.083.2.tar.gz',             0],
);

done_testing;
