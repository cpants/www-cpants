package WWW::CPANTS::Page::Kwalitee;

use strict;
use warnings;
use WWW::CPANTS::DB;
use WWW::CPANTS::Util::JSON;
use WWW::CPANTS::Analyze::Metrics;
use WWW::CPANTS::Utils;

sub title { 'Kwalitee' };

sub load_data { slurp_json('page/kwalitee_overview') }

sub create_data {
  my $class = shift;

  my ($core, $extra, $experimental) = sorted_metrics({}, requires_remedy => 1);

  my $got = db_r('Kwalitee')->fetch_overview;
  for (@$core, @$extra, @$experimental) {
    for my $type (qw/latest cpan backpan/) {
      $_->{"${type}_fails"} = $got->{$type."_".$_->{key}};
      $_->{"${type}_fail_rate"} = percent($_->{"${type}_fails"}, $got->{"${type}_total"});
    }
  }

  save_json('page/kwalitee_overview', {
    latest_total  => $got->{latest_total},
    cpan_total    => $got->{cpan_total},
    backpan_total => $got->{backpan_total},
    core          => $core,
    extra         => $extra,
    experimental  => $experimental,
  });
}

1;

__END__

=head1 NAME

WWW::CPANTS::Page::Kwalitee

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 METHODS

=head2 title

=head2 load_data

=head2 create_data

=head1 AUTHOR

Kenichi Ishigaki, E<lt>ishigaki@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 by Kenichi Ishigaki.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
