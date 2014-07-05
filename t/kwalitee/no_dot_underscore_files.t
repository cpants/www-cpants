use strict;
use warnings;
use WWW::CPANTS::Test;

test_kwalitee('no_dot_underscore_files',
  ['LEPT/String-Iota-0.85.tar.gz', 0], # 2441
  ['DAMOG/Data-Format-HTML-0.5.1.tar.gz', 0], # 2737
  ['BRENTDAX/Template-Plugin-Lingua-Conjunction-0.02.tar.gz', 0], # 2875
  ['SOCK/WWW-Search-UrbanDictionary-0.4.tar.gz', 0], # 3176
  ['CLADI/SmarTalk_v10.tar.gz', 0], # 3289
  ['KAOSAGNT/CGI-Session-Serialize-php-1.1.tar.gz', 0], # 3336
  ['EBRAGIN/Cache-Memcached-Tags-0.02.tar.gz', 0], # 3399
  ['AHICOX/XML-Parser-YahooRESTGeocode-0.2.tar.gz', 0], # 3503
  ['RECSKY/Bot-BasicBot-Pluggable-Module-Pastebin-0.01.tar.gz', 0], # 3663
  ['SOCK/WWW-Yahoo-KeywordExtractor-0.5.2.tar.gz', 0], # 3806
);

done_testing;
