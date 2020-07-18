package WWW::CPANTS::Web::Util::BadgeSVG;

use WWW::CPANTS;
use WWW::CPANTS::Util;
use Badge::Simple;

sub new ($class, $score) {
    $score = sprintf '%.2f', $score if $score =~ /^[0-9.]+$/;
    my $file = app_dir('web/public/img/badge/')->child("$score.svg");
    if (!-f $file) {
        $file->parent->mkpath;
        my $color =
              $score >= 100 ? 'brightgreen'
            : $score >= 99  ? 'green'
            : $score >= 90  ? 'yellowgreen'
            : $score >= 80  ? 'yellow'
            :                 'red';
        Badge::Simple::badge(left => 'kwalitee', right => $score, color => $color)->toFile("$file");
    }
    bless { file => $file }, $class;
}

sub path ($self) {
    $self->{file}->relative(app_dir('web/public'));
}

1;
