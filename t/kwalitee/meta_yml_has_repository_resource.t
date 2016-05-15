use WWW::CPANTS;
use WWW::CPANTS::Test;

test_kwalitee('meta_yml_has_repository_resource',
  ['ISHIGAKI/Acme-CPANAuthors-Japanese-0.131002.tar.gz', 0],
  ['ISHIGAKI/Acme-CPANAuthors-0.23.tar.gz', 1],
);
done_testing;
