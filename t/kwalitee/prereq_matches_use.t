use Mojo::Base -strict, -signatures;
use WWW::CPANTS::Test;

#plan skip_all => 'TODO';

test_kwalitee(
    'prereq_matches_use',
    ['KAWABATA/Text-HikiDoc-1.023.tar.gz',                  0],    # Text::Highlight etc
    ['PVIGIER/XML-Compile-SOAP-Daemon-Dancer2-0.07.tar.gz', 0],    # Log::Report etc
    ['MICKEY/PONAPI-Server-0.003002.tar.gz',                0],    # URI::Escape
    ['TEAM/Net-Async-Pusher-0.004.tar.gz',                  0],    # Syntax::Keyword::Try
);

done_testing;
