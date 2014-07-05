use strict;
use warnings;
use WWW::CPANTS::Test;

test_kwalitee('no_pod_errors',
  ['ALEXP/Catalyst-Model-Proxy-0.04.tar.gz', 0], # 3671
  ['LEEYM/Geo-Coder-Cache-0.06.tar.gz', 0], # 3907
  ['SULLR/Net-PcapWriter-0.71.tar.gz', 0], # 5337
  ['LTP/Game-Life-0.05.tar.gz', 0], # 6535
  ['JHALLOCK/StormX-Query-DeleteWhere-0.10.tar.gz', 0], # 6869
  ['DSYRTM/File-BetweenTree-1.02.tar.gz', 0], # 7590
  ['JHALLOCK/GappX-Dialogs-0.005.tar.gz', 0], # 7766
  ['FIBO/Task-Viral-20130508.tar.gz', 0], # 8128
  ['JSOBRIER/WebService-Browshot-1.11.0.tar.gz', 0], # 9434
  ['SALVA/Class-StateMachine-0.23.tar.gz', 0], # 9859

  # broken pod for testing should not be counted
  ['RJBS/Pod-Elemental-0.103000.tar.gz', 1],
);

done_testing;
