use Mojo::Base -strict, -signatures;
use WWW::CPANTS::Test;

test_kwalitee(
    'has_security_doc',
    # doc/security.pod + emails
    ['HIO/Tripletail-0.65.tar.gz', 1],

    # SECURITY.md + emails
    ['CROMEDOME/Dancer2-1.1.2.tar.gz', 1],

    # SECURITY.md + links
    ['EDF/Geo-What3Words-3.0.3.tar.gz', 1],
    ['MSTEMLE/Net-AMQP-RabbitMQ-2.40014.tar.gz', 1],

    # SECURITY.md + both emails and links
    ['BRIANDFOY/Tie-Cycle-1.229.tar.gz', 1],
    ['STIGTSP/Crypt-URandom-Token-0.003.tar.gz', 1],

    # SECURITY without contact
    ['FSG/Penguin-3.00.tar.gz', 1],
    ['THOMAS/Apache-DnsZone-0.1.tar.gz', 1],

    # No SECURITY
    ['JBERGER/Test-Mojo-WithRoles-0.02.tar.gz', 0],
);

done_testing;
