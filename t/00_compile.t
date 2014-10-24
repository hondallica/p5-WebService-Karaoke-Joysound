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


is $joysound->request_param->{artist}{param}{karaokeall}, 1;
is $joysound->request_param->{artist}{param}{searchType}, '01';
is $joysound->request_param->{artist}{param}{searchWordType}, 1;
is $joysound->request_param->{artist}{param}{searchLikeType}, 3;


my $data = $joysound->search('artist', 'Metallica');
ok $data;
warn Dumper $data;

my $data = $joysound->search('songs', 233048);
ok $data;
warn Dumper $data;


#my $data = $joysound->artist_search('Metal');
#ok $data;
#warn Dumper $data;


#my $data = $joysound->songs_search(233048);
#ok $data;
#warn Dumper $data;

done_testing;

