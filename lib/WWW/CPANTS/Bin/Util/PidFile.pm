package WWW::CPANTS::Bin::Util::PidFile;

use WWW::CPANTS;
use WWW::CPANTS::Bin::Util;

sub new ($class, $name, $force) {
    (my $path = $name) =~ s/\W+/_/g;
    my $file = file("tmp/pid/$path.pid"); $file->parent->mkpath;
    if (-f $file && !$force) {
        my $pid = $file->slurp;
        if (kill 0, $pid) {
            log(notice => "Another $name ($pid) is running");
            exit;
        }
    }
    $file->spew($$);

    bless { file => $file }, $class;
}

sub pid ($self) { -f $self->{file} ? $self->{file}->slurp : undef }

sub is_mine ($self) { ($self->pid // '') eq $$ ? 1 : 0 }

sub DESTROY ($self) {
    my $pid = $self->pid or return;
    $self->{file}->remove if $pid eq $$;
}

1;
