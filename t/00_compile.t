use strict;
use Test::More 0.98;
use Data::Dumper;

use_ok $_ for qw(
    WebService::Karaoke::Joysound
);


my $joysound = new WebService::Karaoke::Joysound;

is $joysound->match->{FORWARD}, 1;
is $joysound->match->{PARTIAL}, 2;
is $joysound->match->{FULL},    3;

isa_ok $joysound->{http}, 'Furl::HTTP';

is $joysound->request_param->{songs}{path}, 'artist.htm';
is $joysound->request_param->{artist}{path}, 'artistsearchword.htm';


my $data = $joysound->search('artist', 'BABYMETAL');
ok $data;
warn Dumper $data;

for my $id (keys %$data) {
    my $data = $joysound->search('songs', $id);
    ok $data, $id . ':' . $data->{$id};
    warn Dumper $data;
}


done_testing;

