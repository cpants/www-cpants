package WWW::CPANTS::Process::Analysis::MetaYML;

use strict;
use warnings;
use WWW::CPANTS::DB;
use WWW::CPANTS::JSON;

sub new {
  bless {
    db => db('MetaYML')->setup,
  }, shift;
}

sub update {
  my ($self, $data) = @_;

  my $meta = $data->{meta_yml};

  return unless $meta && ref $meta eq ref {};

  my $spec_version = 'unknown';
  if (my $meta_spec = $meta->{'meta-spec'}) {
    if (ref $meta_spec eq ref {} && $meta_spec->{version}) {
      $spec_version = $meta_spec->{version};
    }
  }
  my %resources;
  my @custom_keys;
  if ($meta->{resources} && ref $meta->{resources} eq ref {}) {
    %resources = %{$meta->{resources}};
    @custom_keys = grep { /x_/ or /[A-Z]/ } keys %resources;
    push @custom_keys, grep { /x_/ or /[A-Z]/ } keys %$meta;
  }

  # TODO: CPAN::Meta::Spec 2 support

  $self->{db}->bulk_insert({
    analysis_id => $data->{id},
    has_abstract => _is_not_null($meta->{abstract}),
    num_of_authors => _num_of($meta->{author}),
    num_of_requires => _num_of($meta->{requires}),
    num_of_build_requires => _num_of($meta->{build_requires}),
    num_of_test_requires => _num_of($meta->{test_requires}),
    num_of_configure_requires => _num_of($meta->{configure_requires}),
    num_of_recommends => _num_of($meta->{recommends}),
    num_of_conflicts => _num_of($meta->{conflicts}),
    num_of_provides => _num_of($meta->{providesf}),
    is_dynamic => ($meta->{dynamic_config} ? 1 : 0),
    spec => $spec_version,
    generated_by => $meta->{generated_by} || '',
    license => $meta->{license} || '',
    bugtracker => _str($resources{bugtracker}),
    homepage   => _str($resources{homepage}),
    repository => _str($resources{repository}),
    custom_keys => (@custom_keys ? join(',', @custom_keys) : ''),
  });
}

sub _is_not_null { $_[0] && length($_[0]) ? 1 : 0 }

sub _num_of {
  return 0 if !_is_not_null($_[0]);
  return ref $_[0] eq ref [] ? scalar @{$_[0]} : 1;
}

sub _str {
  return '' unless defined $_[0];
  return $_[0] if !ref $_[0];
  return encode_json($_[0]);
}

sub finalize {
  shift->{db}->finalize_bulk_insert;
}

1;

__END__

=head1 NAME

WWW::CPANTS::Process::Analysis::MetaYML

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 METHODS

=head2 new
=head2 update
=head2 finalize

=head1 AUTHOR

Kenichi Ishigaki, E<lt>ishigaki@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2013 by Kenichi Ishigaki.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
