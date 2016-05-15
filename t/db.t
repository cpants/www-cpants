use WWW::CPANTS;
use WWW::CPANTS::Test;
use WWW::CPANTS::DB;

ok my $db = WWW::CPANTS::DB->new;
for my $name ($db->table_names) {
  ok my $table = $db->table($name);
  ok my $schema = $table->handle->schema($table);
  note $schema;
  ok $table->setup;
}

done_testing;
