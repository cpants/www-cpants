use strict;
use warnings;
use WWW::CPANTS::Test;

test_kwalitee('metayml_is_parsable',
  # No META.yml
  ['UNBIT/Net-uwsgi-1.1.tar.gz', 0], # 2409
  ['ANANSI/Anansi-Singleton-0.02.tar.gz', 0], # 2664
  ['NIELSD/Speech-Google-0.5.tar.gz', 0], # 2907
  ['ANANSI/Anansi-Class-0.03.tar.gz', 0], # 3028
  ['ANANSI/Anansi-Actor-0.04.tar.gz', 0], # 3157
  ['ANANSI/Anansi-Library-0.02.tar.gz', 0], # 3365
  ['MANIGREW/SEG7-1.0.1.tar.gz', 0], # 3847
  ['HITHIM/Socket-Mmsg-0.02.tar.gz', 0], # 3946
  ['STEFANOS/Net-SMTP_auth-SSL-0.2.tar.gz', 0], # 4058

  # Stream does not end with newline character
  ['SCILLEY/POE/Component/IRC/Plugin/IRCDHelp-0.02.tar.gz', 0], # 3243
);

done_testing;
