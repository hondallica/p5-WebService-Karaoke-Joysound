use strict;
use Test::More 0.98;
use Data::Dumper;

use_ok $_ for qw(
    WebService::Karaoke::Joysound
);


my $joysound = new WebService::Karaoke::Joysound;


isa_ok $joysound->{http}, 'Furl::HTTP';

is $joysound->request_param->{songs}{path}, 'artist.htm';
is $joysound->request_param->{artist}{path}, 'artistsearchword.htm';

is $joysound->param->{karaokeall}, 1;
is $joysound->param->{searchType}, '01';
is $joysound->param->{searchWordType}, 1;
is $joysound->param->{searchLikeType}, 2;

is $joysound->match_mode('FORWARD'), 1;
is $joysound->match_mode('PARTIAL'), 2;
is $joysound->match_mode('FULL'), 3;

use DBI;
my $dbh = DBI->connect($ENV{HRHMDB});
my $sth = $dbh->prepare('select bandname from bands order by band_id+0 limit 0,10');
$sth->execute;

while (my $row = $sth->fetchrow_hashref) {
    warn Dumper $row->{bandname};
    my $data = $joysound->search('artist', $row->{bandname});
    ok $data;
    warn Dumper $data;

    for my $id (sort keys %$data) {
        my $data = $joysound->search('songs', $id);
        ok $data, $id . ':' . $data->{$id};
        warn Dumper $data;
    }
}

$dbh->disconnect;


done_testing;

