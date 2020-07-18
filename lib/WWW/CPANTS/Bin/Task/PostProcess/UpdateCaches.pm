package WWW::CPANTS::Bin::Task::PostProcess::UpdateCaches;

use Mojo::Base 'WWW::CPANTS::Bin::Task', -signatures;
use WWW::CPANTS::API::Context;
use WWW::CPANTS::Util::Loader;

sub run ($self, @args) {
    @args = submodule_names("WWW::CPANTS::API::Model") unless @args;

    my $ctx = WWW::CPANTS::API::Context->new(verbose => $self->ctx->verbose);
    for my $name (@args) {
        my $module = use_module("WWW::CPANTS::API::Model::$name");
        my $model  = $module->new(ctx => $ctx);
        $model->save and $self->log(info => "cached $name");
    }
}

1;
