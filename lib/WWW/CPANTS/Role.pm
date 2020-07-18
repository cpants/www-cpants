package WWW::CPANTS::Role;

use WWW::CPANTS;
use Role::Basic ();
use Exporter qw/import/;

our @EXPORT = qw/with/;

sub with (@names) {
    my $caller = caller;
    my ($base, $namespace) = $caller =~ /^(WWW::CPANTS::)(.+)/;
    $base .= 'Role';
    my @packages = map { _name($base, $namespace, $_) } @names;
    Role::Basic->apply_roles_to_package($caller, @packages);
}

sub _name ($base, $namespace, $name) {
    if ($name =~ s/^\-//) {
        my ($parent) = $namespace =~ /^(.+)::\w+$/;
        return join '::', $base, $parent, $name;
    }
    if ($name =~ s/^\+//) {
        return join '::', $base, $namespace, $name;
    }
    return join '::', $base, $name;
}

1;
