package WWW::CPANTS::Bin::Task::Notify;

use Mojo::Base 'WWW::CPANTS::Bin::Task', -signatures;
use Furl::HTTP;
use IO::Socket::SSL;
use JSON::XS;
use WWW::CPANTS;

sub run ($self, @args) {
    my $config = WWW::CPANTS->instance->config->{notify} or return;
    if (my $slack = $config->{slack}) {
        my $ua = Furl::HTTP->new(
            ssl_opts => { SSL_verify_mode => SSL_VERIFY_NONE() },
        );
        my $to = $slack->{to} // '@here';
        my ($protocol, $code, $msg, $headers, $body) = $ua->post(
            $slack->{hook},
            ['Content-Type' => 'application/json'],
            encode_json({ text => "<$to> $0 has ended" }),
        );
    }
}

1;
