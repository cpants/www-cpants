package WWW::CPANTS::Test;

use WWW::CPANTS;
use WWW::CPANTS::Util;
use Exporter qw/import/;
use Test::More;
use WorePAN;
use URI;
use LWP::UserAgent;
use LWP::Protocol::PSGI;

our @EXPORT = (
  @Test::More::EXPORT,
  qw/
    setup_mirror
    requires_network
    get_cpants_api_ok
    register_local_api
    test_kwalitee
    test_network
  /,
);

my ($Pid, $WorePAN);

BEGIN { $ENV{EMAIL_SENDER_TRANSPORT} = 'Test' }

sub setup_mirror (@files) {
  my %opts = (ref $files[-1] eq 'HASH') ? %{pop @files} : ();

  unless (@files) {
    @files = qw{ISHIGAKI/Path-Extended-0.19.tar.gz};
  }

  my $mirror = dir('mirror'); $mirror->mkpath;
  my $local_mirror = app_dir('tmp/test_mirror'); $local_mirror->mkpath;
  $WorePAN = WorePAN->new(
    root => $mirror->path,
    local_mirror => $local_mirror->path,
    files => \@files,
    no_network => 0,
    no_indices => defined $opts{no_indices} ? $opts{no_indices} : 1,
    use_backpan => 1,
  );
  my $iter = $mirror->iterator({recurse => 1, follow_symlinks => 0});
  while(my $e = $iter->()) {
    next unless -f $e;
    my $path = $e->relative($mirror)->path;
    my $local_copy = $local_mirror->child($path);
    if (!$local_copy->exists) {
      $local_copy->parent->mkpath;
      $e->copy($local_copy);
    }
  }
  $Pid = $$;
  $WorePAN;
}

sub requires_network ($host) {
  require Socket;
  eval { Socket::inet_aton($host) }
    or plan skip_all => "This test requires network to $host";
}

sub get_cpants_api_ok ($subdomain, $path, $query = {}) {
  my $url = URI->new("http://$subdomain.cpanauthors.org");
  $url->path($path);
  $url->query_form($query);
  note $url;
  my $ua = LWP::UserAgent->new(agent => "WWW::CPANTS::Test");
  my $res = $ua->get($url);
  ok $res->is_success;
  decode_json($res->decoded_content);
}

sub register_local_api ($psgi_file) {
  my $psgi = do $psgi_file;
  LWP::Protocol::PSGI->register($psgi);
}

sub test_kwalitee ($name, @tests) {
  my $mirror = setup_mirror(map {$_->[0]} @tests);

  require WWW::CPANTS::Bin::Task::Analyze;
  my $task = WWW::CPANTS::Bin::Task::Analyze->new;

  for my $test (@tests) {
    my $path = $test->[0];
    $path =~ s!^([A-Z])([A-Z0-9])([A-Z0-9_-]+/.+)$!$1/$1$2/$1$2$3!;
    my $stash = $task->analyze_file($mirror->file($path))->stash;
    my $result = $stash->{kwalitee}{$name} // '';
    is $result => $test->[1], $test->[0] . " $name: $result" or note explain $stash;

    if ($test->[2]) {
      if (ref $test->[2] eq ref sub {}) {
        $test->[2]->($stash);
      } else {
        note explain $stash;
      }
    }
  }
}

sub test_network ($host) {
  require Socket;
  eval { Socket::inet_aton($host) }
    or plan skip_all => "This test requires network to $host";
}

END {
  $WorePAN->root->remove if $WorePAN && $Pid && $Pid == $$;
}

1;
