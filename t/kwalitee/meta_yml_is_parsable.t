use Mojo::Base -strict, -signatures;
use WWW::CPANTS::Test;

test_kwalitee(
    'meta_yml_is_parsable',
    # No META.yml
    ['UNBIT/Net-uwsgi-1.1.tar.gz', 1],    # 2409

    # Stream does not end with newline character
    ['SCILLEY/POE/Component/IRC/Plugin/IRCDHelp-0.02.tar.gz', 0],    # 3243

    # Error reading from file: utf8 "\xB0" does not map to Unicode
    ['WINTRU/Mica-1.a.0.tar.gz', 0],                                 # 1196

    # CPAN::Meta::YAML does not support a feature in line
    ['STRO/Task-CPANAuthors-STRO-PPMCreator-2009.1018.tar.gz', 0],    # 1555

    # CPAN::Meta::YAML failed to classify line ' --- #YAML:1.0'
    ['XPANEL/XPanel-0.0.7.tar.gz', 0],                                # 2207

    # CPAN::Meta::YAML found bad indenting
    ['NUFFIN/Devel-STDERR-Indent-0.01.tar.gz', 0],                    # 2594

    # CPAN::Meta::YAML found illegal characters
    ['SOCK/WWW-Search-Feedster-0.02.tar.gz', 0],                      # 3220
);

done_testing;
