package WWW::CPANTS::Bin::Task::Traverse;

use WWW::CPANTS;
use WWW::CPANTS::Bin::Util;
use parent 'WWW::CPANTS::Bin::Task';
use List::Util qw/max/;

sub option_specs {(
  ['pause_id=s', 'pause_id to traverse'],
)}

sub run ($self, @args) {
  my $backpan = $self->backpan;
  my $cpan = $self->cpan;
  my $db = $self->db;
  $db->advisory_lock(qw/Uploads/) or return;
  my $authors = $db->table('Authors');
  my $pause_ids = $self->option('pause_id')
    ? [split ',', $self->option('pause_id')]
    : $authors->select_all_pause_ids_ordered_by_cpan_dists;

  my $uploads = $db->table('Uploads');
  my $kwalitee = $db->table('Kwalitee');
  my @tables = map {$db->table($_)} qw/Analysis Provides RequiresAndUses Resources/;

  my $update_dists = $self->task('Traverse::UpdateDistributions')->setup;
  my $update_author_json = $self->task('Traverse::UpdateAuthorJson')->setup;

  my $done = 0;
  my $total = @$pause_ids;
  for my $pause_id (@$pause_ids) {
    if ($done++ and !($done % 100)) {
      $self->show_progress($done, $total) 
    }
    log(info => "$pause_id");
    my @new;
    my $backpan_dir = $backpan->author_dir($pause_id);
    my $cpan_authors_id_dir = $cpan->authors_id_dir;
    unless (-d $backpan_dir) {
      log(debug => "$pause_id doesn't have a dist");
      $authors->update_cpan_info($pause_id, {
        cpan_dists => 0,
        last_released_at => undef,
      });
      next;
    }
    my %paths = map {$_->{path} => $_} @{$uploads->select_all_by_author($pause_id) // []};
    my $iter = $backpan_dir->iterator({recurse => 1, follow_symlinks => 0});
    my %cpan_dists;
    while(my $file = $iter->()) {
      next if -d $file;
      # $file->relative is rather slow
      # NB. there may be another authors/id/ part in the middle (BILLW/authors/id/...)
      my $fullpath = $file->stringify;
      $fullpath =~ s|\\|/|g if $^O eq 'MSWin32';
      my ($path) = $fullpath =~ m|^.*?authors/id/(.+)$|;
      if ($path =~ m!/author(?:\-\d+)?\.json$!) {
        $update_author_json->update($pause_id, $file);
      }
      my $info = distinfo($path) or next;
      next if $info->{perl6};
      my $uid = path_uid($info->{path});
      my $dist = $info->{dist};
      if (!exists $paths{$path}) {
        my $is_cpan = $cpan_authors_id_dir->child($path)->exists ? 1 : 0;
        my $released = int(file_mtime($file)) // 0;
        my $version_number = numify_version($info->{version});
        my $stable = $info->{maturity} eq 'released' ? 1 : 0;
        push @new, {
          uid => $uid,
          path => $info->{path},
          author => $info->{cpanid},
          name => $dist,
          version => $info->{version},
          version_number => $version_number,
          released => $released,
          year => year($released),
          cpan => $is_cpan,
          stable => $stable,
        };
        if ($is_cpan) {
          $cpan_dists{$dist} = $released if ($cpan_dists{$dist} // 0) < $released;
        }

        $update_dists->add_dist_uid($dist, $uid, {
          uid => $uid,
          author => $info->{cpanid},
          version => $info->{version},
          version_number => $version_number,
          released => $released,
          cpan => $is_cpan,
          stable => $stable,
        });
      } elsif ($paths{$path}{cpan}) {
        if ($cpan_authors_id_dir->child($path)->exists) {
          my ($dist, $released) = @$info{qw/dist released/};
          $cpan_dists{$dist} = $paths{$path}{released} if ($cpan_dists{$dist} // 0) < $paths{$path}{released};
          $update_dists->mark_cpan($dist, $uid);
        } else {
          $uploads->mark_backpan($uid);
          $update_dists->mark_backpan($dist, $uid);
        }
      } else {
        # enable this only when something went wrong
        if ($cpan_authors_id_dir->child($path)->exists) {
          my ($dist, $released) = @$info{qw/dist released/};
          $cpan_dists{$dist} = $paths{$path}{released} if ($cpan_dists{$dist} // 0) < $paths{$path}{released};
          $uploads->mark_cpan($uid);
          $update_dists->mark_cpan($dist, $uid);
        }
      }
      $paths{$path} = undef;
    }
    $authors->update_cpan_info($pause_id, {
      cpan_dists => scalar keys %cpan_dists,
      last_released_at => max values %cpan_dists,
    });
    if (@new) {
      my $ct = @new;
      my @uids = map {+{uid => $_->{uid}}} @new;
      log(info => "inserted $ct files for $pause_id");
      $uploads->bulk_insert(\@new);
      $kwalitee->bulk_insert(\@new);
      for my $table (@tables) {
        $table->bulk_insert(\@uids, {ignore => 1});
      }
    }

    # just in case
    if (my @deleted = grep {defined $paths{$_}} keys %paths) {
      my @uids = map {path_uid($_)} @deleted;
      $uploads->delete_by_uids(\@uids);
      for my $table (@tables) {
        $table->delete_by_uids(\@uids);
      }
    }
  }
  $update_dists->update;
}

1;
