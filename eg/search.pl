#!/usr/local/bin/perl

use strict;
use warnings;
use Data::Dumper;
use WebService::AndroidMarketAPI;

@ARGV == 3 or die "$0 username password query";

my $username = $ARGV[0];
my $password = $ARGV[1];
my $query    = $ARGV[2];

my $api = WebService::AndroidMarketAPI->new(
    context_args => {
        userLanguage => 'ja',
        userCountry => 'JP',
        operatorAlpha => 'NTT DOCOMO',
        simOperatorAlpha => 'NTT DOCOMO',
        operatorNumeric => '44010',
        simOperatorNumeric => '44010',
    },
);
$api->login( $username, $password );
my $res = $api->search( {
    query            => $query,
    withExtendedInfo => 1,
    entriesCount     => 10,
} );

for my $res_group ( @{ $res->ResponseGroup } ) {
    my $apps_response = $res_group->appsResponse;
    for my $app ( @{ $apps_response->app } ) {
        warn Dumper $app;
        my $res = $api->comments( { appId => $app->id } );
        for my $comments_res_group ( @{ $res->ResponseGroup } ) {
            my $comments_res = $comments_res_group->commentsResponse;
            if ( ref $comments_res->comments eq 'ARRAY' ) {
                for my $comment ( @{ $comments_res->comments } ) {
                    warn Dumper $comment;
                }
            }
        }
    }
}

