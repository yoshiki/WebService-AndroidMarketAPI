package WebService::AndroidMarketAPI;
use strict;
use warnings;
use base qw( Class::Accessor::Fast );
use Net::Google::AuthSub;
use Google::ProtocolBuffers;
use MIME::Base64;
use LWP::UserAgent;
use HTTP::Request;
use HTTP::Headers;
use IO::Uncompress::Gunzip qw(gunzip $GunzipError);
use File::ShareDir qw( dist_file );

our $VERSION = '0.01';

__PACKAGE__->mk_accessors( qw( auth ) );

sub new {
    my $class = shift;
    my %args = @_;
    my $self = bless \%args, $class;
    _parse_protocol_buffers();
    return $self;
}

sub login {
    my ( $self, $username, $password ) = @_;
    my $auth = Net::Google::AuthSub->new( service => 'android' );
    my $response = $auth->login( $username, $password );
    unless ( $response->is_success ) {
        die 'Authentication failed: ' . $response->error;
    }
    $self->auth( $auth );
    return $auth;
}

sub _parse_protocol_buffers {
    my $protofile = dist_file( 'WebService-AndroidMarketAPI', 'market.proto' );
    Google::ProtocolBuffers->parsefile(
        $protofile, {
            create_accessors => 1,
        }
    );
}

sub context {
    my $self = shift;
    unless ( $self->{ context } ) {
        my $context = RequestContext->new( {
            unknown1            => $self->{ context_args }->{ unknown1 } || 0,
            version             => $self->{ context_args }->{ version } || 1002012,
            androidId           => $self->{ context_args }->{ androidId } || "0123012301230123",
            deviceAndSdkVersion => $self->{ context_args }->{ deviceAndSdkVersion } || "passion:8",
            userLanguage        => $self->{ context_args }->{ userLanguage } || "en",
            userCountry         => $self->{ context_args }->{ userCountry } || "US",
            operatorAlpha       => $self->{ context_args }->{ operatorAlpha } || "T-Mobile",
            simOperatorAlpha    => $self->{ context_args }->{ simOperatorAlpha } || "T-Mobile",
            operatorNumeric     => $self->{ context_args }->{ operatorNumeric } || "310260",
            simOperatorNumeric  => $self->{ context_args }->{ simOperatorNumeric } || "310260",
            authSubToken        => $self->auth->auth_token,
        } );
        $self->{ context } = $context;
    }
    return $self->{ context };
}

sub request {
    my ( $self, $body ) = @_;
    my $url = 'http://android.clients.google.com/market/api/ApiRequest';
    my %params = $self->auth->auth_params;
    my $request = HTTP::Request->new(
        'POST', $url,
        HTTP::Headers->new(
            User_Agent     => 'Android-Market/2 (sapphire PLAT-RC33); gzip',
            Content_Type   => 'application/x-www-form-urlencoded',
            Accept_Charset => 'ISO-8859-1,utf-8;q=0.7,*;q=0.7',
            Content_Length => length $body,
            %params,
        ),
        $body,
    );
    my $ua = LWP::UserAgent->new;
    my $res = $ua->request( $request );
    if ($res->is_success) {
        my $input = $res->content;
        my $output;
        gunzip \$input => \$output
            or die "gunzip failed: $GunzipError";
        my $res = Response->decode($output);
        return $res;
    }
    else {
        die $res->status_line;
    }
}

sub search {
    my ( $self, $args ) = @_;
    $args->{ startIndex } ||= 0;
    $args->{ entriesCount } ||= 5;

    my $ar = AppsRequest->new( $args );
    my $req_group = Request::RequestGroup->new;
    $req_group->appsRequest( [ $ar ] );

    my $req = Request->new;
    $req->context( $self->context );
    $req->RequestGroup( $req_group );

    ( my $req_str = encode_base64( $req->encode ) ) =~ s/\r?\n//g;
    my $body = 'version=2&request=' . $req_str;
    return $self->request( $body );
}

sub comments {
    my ( $self, $args ) = @_;
    $args->{ startIndex } ||= 0;
    $args->{ entriesCount } ||= 5;

    my $cr = CommentsRequest->new( $args );
    my $req_group = Request::RequestGroup->new;
    $req_group->commentsRequest( [ $cr ] );

    my $req = Request->new;
    $req->context( $self->context );
    $req->RequestGroup( $req_group );

    ( my $req_str = encode_base64( $req->encode ) ) =~ s/\r?\n//g;
    my $body = 'version=2&request=' . $req_str;
    return $self->request( $body );
}

1;
__END__

=head1 NAME

WebService::AndroidMarketAPI -

=head1 SYNOPSIS

  use WebService::AndroidMarketAPI;

=head1 DESCRIPTION

WebService::AndroidMarketAPI is

=head1 AUTHOR

Yoshiki Kurihara E<lt>kurihara at cpan.orgE<gt>

=head1 SEE ALSO

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
