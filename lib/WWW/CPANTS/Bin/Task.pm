package WWW::CPANTS::Bin::Task;

use WWW::CPANTS;
use WWW::CPANTS::Bin::Util;
use WWW::CPANTS::DB;

sub option_specs {}

sub new ($class, $ctx = {}) {
  bless {ctx => $ctx}, $class;
}

sub name ($self) {
  my ($name) = (ref $self // $self) =~ /^WWW::CPANTS::Bin::Task::(.+)$/;
  $name;
}

sub run_and_log ($self, @args) {
  my $name = $self->name;
  $self->{timer} = timer($name);
  $self->run(@args);
  delete $self->{timer};
  save_json("task/".package_path_name($name), {last_executed => time})
}

sub show_progress ($self, $done, $total) {
  return unless $self->development_mode;

  $self->{timer}->show_progress($done, $total);
}

sub development_mode ($self) {
  $self->{development_mode} //= do {
    my $ctx = WWW::CPANTS->context or return 0;
    $ctx->_mode_is('development');
  };
}

sub args ($self) { $self->{ctx}{args} }

sub stash ($self) { $self->{ctx}{stash} }

sub option ($self, $name) {
  $self->{ctx}{opts}{$name};
}

sub db ($self) { $self->{ctx}->db }

sub new_db ($self) { $self->{ctx}->new_db }

sub model ($self, $name, @args) {
  ($self->{model_class}{$name} //= use_module("WWW::CPANTS::Bin::Model::".$name))->new(@args);
}

sub task ($self, $name) { $self->{ctx}->task($name) }

sub cpan ($self) {
  $self->{ctx}{cpan} //= $self->model('CPAN');
}

sub backpan ($self) {
  $self->{ctx}{backpan} //= $self->model('BackPAN');
}

1;
