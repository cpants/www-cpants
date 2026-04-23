use Mojo::Base -strict, -signatures;
use WWW::CPANTS::Test;

test_kwalitee(
    'security_doc_contains_contact',
    # email
    ['RRWO/Data-Enum-v0.6.0.tar.gz', 1],
    ['BRIANDFOY/Tie-Timely-1.026.tar.gz', 1],

    # link
    ['FASTLY/WebService-Fastly-7.00.tar.gz', 1],
    ['MSTEMLE/Net-AMQP-RabbitMQ-2.40014.tar.gz', 1],

    # SECURITY without contact
    ['FSG/Penguin-3.00.tar.gz', 0],
    ['THOMAS/Apache-DnsZone-0.1.tar.gz', 0],
);

done_testing;
