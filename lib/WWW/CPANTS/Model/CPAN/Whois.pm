package WWW::CPANTS::Model::CPAN::Whois;

use Role::Tiny::With;
use Mojo::Base -base, -signatures;
use Parse::CPAN::Whois;
use WWW::CPANTS::Util::Datetime;

has 'path'    => 'authors/00whois.xml';
has 'authors' => \&_build_authors;

with qw/WWW::CPANTS::Role::CPAN::Index/;

our %SYSTEM_USER = map { $_ => 1 } qw(
    ADOPTME
    HANDOFF
    NEEDHELP
    NOXFER
    PAUSE
    RECAPTCHA
);

sub _build_authors ($self) {
    my $file = $self->fetch;

    $XML::SAX::ParserPackage = "XML::LibXML::SAX";
    my %authors;
    for my $author (Parse::CPAN::Whois->new("$file")->authors) {
        my $pause_id = $author->{id};

        $authors{$pause_id} = {
            pause_id    => $pause_id,
            name        => $author->{fullname},
            ascii_name  => $author->{asciiname}   // $author->{fullname},
            email       => $author->{email}       // '',
            homepage    => $author->{homepage}    // '',
            has_cpandir => $author->{has_cpandir} // 0,
            introduced  => $author->{introduced}  // 0,
            year        => year($author->{introduced} // 0),
            nologin     => $author->{nologin} // 0,
            deleted     => $author->{deleted} // 0,
            system      => (exists $SYSTEM_USER{$pause_id} ? 1 : 0),
        };
    }
    \%authors;
}

sub list ($self) {
    my @rows = values $self->authors->%*;
    \@rows;
}

sub preload ($self) { $self->authors }

1;
