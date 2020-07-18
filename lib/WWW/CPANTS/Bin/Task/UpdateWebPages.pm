package WWW::CPANTS::Bin::Task::UpdateWebPages;

use WWW::CPANTS;
use WWW::CPANTS::Bin::Util;
use WWW::CPANTS::Web::Util ();
use parent 'WWW::CPANTS::Bin::Task';

sub run ($self, @args) {
    @args = findallmod "WWW::CPANTS::Web::Page" unless @args;

    for my $name (@args) {
        $name =~ s/^WWW::CPANTS::Web::Page:://;
        WWW::CPANTS::Web::Util::page($name)->save and log(info => "created $name");
    }

    log(info => "updated web pages");
}

1;
