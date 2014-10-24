package WebService::Karaoke::Joysound;
use JSON::XS;
use Cache::LRU;
use Net::DNS::Lite;
use Furl;
use URI;
use URI::QueryParam;
use HTML::Entities;
use Carp;
use Moo;
use namespace::clean;
our $VERSION = "0.01";
use Data::Dumper;


has 'match' => (
    is => 'ro',
    required => 1,
    default => sub {
        {
            FORWARD => 1,
            PARTIAL => 2,
            FULL => 3,
        }, 
    },
);

$Net::DNS::Lite::CACHE = Cache::LRU->new( size => 512 );

has 'param' => (
    is => 'rw',
    requires => 1,
    default => sub {
        return {
            karaokeall => 1,
            searchType => '01',
            searchWordType => 1,
            searchLikeType => 1,
        };
    },
);


has 'http' => (
    is => 'rw',
    required => 1,
    default  => sub {
        return Furl::HTTP->new(
            inet_aton => \&Net::DNS::Lite::inet_aton,
            agent => 'WebService::Karakoke::Joysound/' . $VERSION,
            headers => [ 'Accept-Encoding' => 'gzip',],
        );
    },
);


has 'request_param' => (
    is => 'rw',
    required => 1,
    default => sub { {
        artist => {
            path => 'artistsearchword.htm',
            regex => qr|<td class="singer"><a href="(?<url>.+)">(?<name>.+)</a></td>|,
            param => {
                karaokeall => 1,
                searchType => '01',
                searchWordType => 1,
                searchLikeType => 3,
            },
            id => 'artistId',
        },
        songs => {
            path => 'artist.htm',
            regex => qr|<td class="title"><a href="(?<url>.+)">(?<name>.+)</a></td>|,
            id => 'gakkyokuId',
        },
    } },
);


sub _make_query_param {
    my ($self, $mode, $search_word) = @_;

    my $url = URI->new;
    map { $url->query_param( $_, $self->param->{$_} ) } keys %{$self->param};
    if ($mode eq 'artist') {
        $url->query_param('searchWord', $search_word);
    } elsif ($mode eq 'songs') {
        $url->query_param('artistId', $search_word);
    }
    return $url;
}


sub search {
    my ($self, $mode, $search_word) = @_;

    my %data = ();
    my $url = $self->_make_query_param($mode, $search_word);
    my $html = $self->request(
        $self->{request_param}{$mode}{path} . $url, 
        $search_word
    );

    my @lines = split /\n/, $html;
    for my $line (@lines) {
        my $regex = $self->{request_param}{$mode}{regex};
        if ($line =~ m|$regex|) {
            my $id = URI->new($+{url})
                        ->query_param($self->request_param->{$mode}{id});
            $data{$id} = decode_entities $+{name};
        }
    }
    
    return \%data;
}

sub request {
    my ( $self, $path, $search_word ) = @_;

    my ($version, $status, $message, $headers, $content) = $self->http->request(
        scheme => 'http',
        host => 'joysound.com',
        path_query => "ex/search/$path",
        method => 'GET',
    );

    confess $message if $status != 200;
    return $content;

}


1;
__END__

=encoding utf-8

=head1 NAME

WebService::Karaoke::Joysound - カラオケJoysoundの検索フォームラッパー

=head1 SYNOPSIS

    use WebService::Karaoke::Joysound;

    my $joysound = new WebService::Karaoke::Joysound;

    my $data = $joysound->search('artist', 'Metallica');
    $data = $joysound->search('songs', 233048);

=head1 DESCRIPTION

カラオケJoysoundの検索フォームラッパー

=head1 METHODS

=head3 artist_search

    my $res = $joysound->artist_search('Metallica');

=head1 LICENSE

Copyright (C) Hondallica.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

Hondallica E<lt>hondallica@gmail.comE<gt>

=cut

