package WWW::CPANTS::Util::Datetime;

use Mojo::Base -strict, -signatures;
use Exporter qw/import/;
use Time::Moment;
use Time::Zone qw/tz_local_offset/;

our @EXPORT = qw(
    strftime ymd ymdhms days_ago year datetime
    epoch_from_date
);

our $TZ_OFFSET = tz_local_offset() / 60;

sub _from_epoch ($epoch = time) {
    Time::Moment->from_epoch($epoch // time)->with_offset_same_instant($TZ_OFFSET);
}

sub strftime ($format, $epoch = time) {
    _from_epoch($epoch // time)->strftime($format);
}

sub ymd ($epoch) { strftime('%F', $epoch) }

sub ymdhms ($epoch) { strftime('%F %T', $epoch) }

sub datetime ($epoch) { strftime('%FT%TZ', $epoch) }

sub year ($epoch) { _from_epoch($epoch)->year }

sub days_ago ($days) { _from_epoch()->minus_days($days) }

sub epoch_from_date ($date) {
    my ($year, $month, $day) = split '-', $date;
    Time::Moment->new(
        year  => $year,
        month => $month,
        day   => $day,
    )->epoch;
}

1;
