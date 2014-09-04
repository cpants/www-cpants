package WWW::CPANTS::DB::MetaYML;

use strict;
use warnings;
use base 'WWW::CPANTS::DB::Base';
use Scope::OnExit;

sub _columns {(
  [analysis_id => 'integer not null', {bulk_key => 1}],
  [has_abstract => 'integer'],
  [num_of_authors => 'integer'],
  [num_of_requires => 'integer'],
  [num_of_build_requires => 'integer'],
  [num_of_test_requires => 'integer'],
  [num_of_configure_requires => 'integer'],
  [num_of_provides => 'integer'],
  [is_dynamic => 'integer'],
  [spec => 'text'],
  [generated_by => 'text'],
  [license => 'text'],
  [bugtracker => 'text'],
  [homepage => 'text'],
  [repository => 'text'],
  [custom_keys => 'text'],
)}

sub _indices {(
  unique => ['analysis_id'],
)}

sub fetch_urls {
  my ($self, $analysis_id) = @_;
  $self->fetch('select bugtracker, homepage, repository from meta_yml where analysis_id = ?', $analysis_id);
}

1;

__END__

=head1 NAME

WWW::CPANTS::DB::MetaYML

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 METHODS

=head2 fetch_urls

=head1 AUTHOR

Kenichi Ishigaki, E<lt>ishigaki@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2013 by Kenichi Ishigaki.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
