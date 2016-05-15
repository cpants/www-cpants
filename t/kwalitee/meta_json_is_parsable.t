use WWW::CPANTS;
use WWW::CPANTS::Test;

test_kwalitee('meta_json_is_parsable',
  # invalid control characters in abstract
  ['JOHND/Data-Properties-YAML-0.04.tar.gz', 0], # \r
  ['WINFINIT/Catalyst-Plugin-ModCluster-0.02.tar.gz', 0], # \t
  ['LIKHATSKI/Ubic-Watchdog-Notice-0.31.tar.gz', 0], # \@

  # '"' expected
  ['SHURD/DMTF-CIM-WSMan-v0.09.tar.gz', 0],
  ['RFREIMUTH/RandomJungle-0.05.tar.gz', 0],

  # VMS
  ['PFAUT/VMS-Time-0_1.zip', 0],

  # malformed JSON string
  ['MAXS/Palm-MaTirelire-1.12.tar.gz', 0], # \x{fffd}

  # illegal backslash escape sequence
  ['JHTHORSEN/Convos-0.6.tar.gz', 0],

  # missing trailing comma (seemingly edited by hand)
  ['PLOCKABY/TAP-Formatter-BambooExtended-1.01.tar.gz', 0],
);

done_testing;
