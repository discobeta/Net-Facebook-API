package Net::Facebook::API;

use 5.008005;
use strict;
use warnings;
use LWP::UserAgent;
use URI::Escape;
use MIME::Base64::URLSafe;
use Digest::SHA qw(hmac_sha256);
use JSON::XS;
use Carp qw(croak);
require Exporter;
use AutoLoader qw(AUTOLOAD);

our @ISA = qw(Exporter);

# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.

our %EXPORT_TAGS = ( 'all' => [ qw(get_api_to_scalar get_accounts get_user get_friends get_newsfeed get_wall get_likes get_movies get_music get_books get_notes get_photo_tags get_photo_albums get_video_tags get_events get_groups get_checkins get_signed_request get_authorize_url get_access_token) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

#our @EXPORT = qw(get_api_to_scalar get_accounts get_user get_friends get_newsfeed get_wall get_likes get_movies get_music get_books get_notes get_photo_tags get_photo_albums get_video_tags get_events get_groups get_checkins get_signed_request get_authorize_url get_access_token);

our @EXPORT = qw( );

our $VERSION = '0.07';

sub new {
    my ($class,%arg) = @_;
    my $self = {};
    $self->{options} = \%arg;
    $self->{options}->{authorize_url} = "https://graph.facebook.com/oauth/authorize";
    $self->{options}->{access_token_url} = "https://graph.facebook.com/oauth/access_token";
    $self->{options}->{http_request_method} = "post",
    $self->{options}->{display} = "page";
    return bless($self,$class);
}

sub get_api_to_scalar {
    my ($self,%opt) = @_;
    if (!$opt{access_token}) { croak "get_api_to_scalar requires access_token to be set"; }
    if (!$opt{url}) { croak "get_api_to_scalar requires url to be set"; }
    my $access_token;
    if ($opt{access_token}) { $access_token = $opt{access_token}; } else { $access_token = $opt{access_token}; }
    my $info = LWP::UserAgent->new->get(
					 $opt{url}."?access_token=".$opt{access_token},
					 %opt)->as_string;
    $info =~ m/\n\n(.+)/;
    my @hash = decode_json $1;
    return @hash;
}

sub get_accounts { 
    my ($self,%opt) = @_; 
    return Net::Facebook::API->get_api_to_scalar(
						 access_token => $opt{access_token},
						 url => 'https://graph.facebook.com/me/accounts'); 
}

sub get_user  { my ($self,%opt) = @_; return Net::Facebook::API->get_api_to_scalar(         access_token => $opt{access_token}, url => 'https://graph.facebook.com/me'); }
sub get_friends { my ($self,%opt) = @_; return Net::Facebook::API->get_api_to_scalar(       access_token => $opt{access_token}, url => 'https://graph.facebook.com/me/friends');}
sub get_newsfeed { my ($self,%opt) = @_; return Net::Facebook::API->get_api_to_scalar(      access_token => $opt{access_token}, url => 'https://graph.facebook.com/me/home'); }
sub get_wall { my ($self,%opt) = @_; return Net::Facebook::API->get_api_to_scalar(    access_token => $opt{access_token}, url => 'https://graph.facebook.com/me/feed'); }
sub get_likes { my ($self,%opt) = @_; return Net::Facebook::API->get_api_to_scalar(         access_token => $opt{access_token}, url => 'https://graph.facebook.com/me/likes'); }
sub get_movies { my ($self,%opt) = @_; return Net::Facebook::API->get_api_to_scalar(        access_token => $opt{access_token}, url => 'https://graph.facebook.com/me/movies'); }
sub get_music { my ($self,%opt) = @_; return Net::Facebook::API->get_api_to_scalar(         access_token => $opt{access_token}, url => 'https://graph.facebook.com/me/music'); }
sub get_books { my ($self,%opt) = @_; return Net::Facebook::API->get_api_to_scalar(         access_token => $opt{access_token}, url => 'https://graph.facebook.com/me/books'); }
sub get_notes { my ($self,%opt) = @_; return Net::Facebook::API->get_api_to_scalar(         access_token => $opt{access_token}, url => 'https://graph.facebook.com/me/notes'); }
sub get_photo_tags { my ($self,%opt) = @_; return Net::Facebook::API->get_api_to_scalar(    access_token => $opt{access_token}, url => 'https://graph.facebook.com/me/photos'); }
sub get_photo_albums { my ($self,%opt) = @_; return Net::Facebook::API->get_api_to_scalar(  access_token => $opt{access_token}, url => 'https://graph.facebook.com/me/albums'); }
sub get_video_tags { my ($self,%opt) = @_; return Net::Facebook::API->get_api_to_scalar(    access_token => $opt{access_token}, url => 'https://graph.facebook.com/me/videos'); }
sub get_video_uploads { my ($self,%opt) = @_; return Net::Facebook::API->get_api_to_scalar( access_token => $opt{access_token}, url => 'https://graph.facebook.com/me/videos/uploaded'); }
sub get_events { my ($self,%opt) = @_; return Net::Facebook::API->get_api_to_scalar(access_token => $opt{access_token}, url => 'https://graph.facebook.com/me/events'); }
sub get_groups { my ($self,%opt) = @_; return Net::Facebook::API->get_api_to_scalar(access_token => $opt{access_token}, url => 'https://graph.facebook.com/me/groups'); }
sub get_checkins { my ($self,%opt) = @_; return Net::Facebook::API->get_api_to_scalar(access_token => $opt{access_token}, url => 'https://graph.facebook.com/me/checkins'); }

sub get_authorize_url {
    my ($self,%opt) = @_;
    if (!$opt{authorize_url} && !$self->{options}->{authorize_url}) { die "get_authorize_url requires authorize_url to be set"; }
    my $auth_url;
    if ($opt{authorize_url}) { $auth_url = $opt{authorize_url}."?"; } else { $auth_url = $self->{options}->{authorize_url}."?"; }
    for (qw(scope display)) {
	if ($opt{$_} || $self->{options}->{$_}) {
	    if ($opt{$_}) { $auth_url .= $_."=".uri_escape($opt{$_}); } else { $auth_url .= $_."=".uri_escape($self->{options}->{$_}); }
	    $auth_url .= "&";
	}
    }
    for (qw(client_id redirect_uri)) {
        if (!$opt{$_} && !$self->{options}->{$_}) { die "get_authorize_url requires $_ to be set"; }
        if ($opt{$_}) { $auth_url .= $_."=".uri_escape($opt{$_}); } else { $auth_url .= $_."=".uri_escape($self->{options}->{$_}); }
        $auth_url .= "&";
    }
    $auth_url =~ s/\&+$//;
    return $auth_url;
}

sub get_access_token {
    my ($self,%opt) = @_;
    my $token_url;
    my $token;
    if ($opt{access_token_url}) { $token_url = $opt{access_token_url}."?"; } else { $token_url = $self->{options}->{access_token_url}."?"; }
    for (qw(redirect_uri client_id client_secret code)) {
	# avoid confusing fb with old code param in redirect_uri, facebook read it as last value
	if (!$opt{$_} && !$self->{options}->{$_}) { croak "get_access_token requires $_ to be set"; }
	if ($opt{$_}) { $token_url .= $_."=".uri_escape($opt{$_}); } else { $token_url .= $_."=".uri_escape($self->{options}->{$_}); }
	$token_url .= "&";
    }
    $token = LWP::UserAgent->new->get($token_url)->as_string();
    $token =~ m/access_token=(.+)/;
    if ($token =~ /OAuthException/) {
	$token =~ m/message":"(.+)"/; #"
	croak "get_access_token returned OAuthException $1";
    }
    $self->{access_token} = $1 if $1;
    return $1;
}

sub get_signed_request {
    my ($self,%opt) = @_;
    for (qw(signed_request client_id client_secret)) {
	if (!$opt{$_} && !$self->{options}->{$_}) { die "get_signed_request requires $_ to be set"; }
    }
    my $signed_request;
    my $client_id;
    my $client_secret;
    if ($opt{signed_request}) { $signed_request = $opt{signed_request}; } else { $signed_request = $self->{options}->{signed_request}; }
    if ($opt{client_id}) { $client_id = $opt{client_id}; } else { $client_id = $self->{options}->{client_id}; }
    if ($opt{client_secret}) { $client_secret = $opt{client_secret}; } else { $client_secret = $self->{options}->{client_secret}; }
    my ($encoded_sig, $payload) = split(/\./, $signed_request);
    my $sig = urlsafe_b64decode($encoded_sig);
    my $data = JSON->new->decode(urlsafe_b64decode($payload));
    if (uc($data->{'algorithm'}) ne "HMAC-SHA256") { croak "get_signed_request returned bad algorithm"; }
    my $expected_sig = hmac_sha256($payload, $client_secret);
    if ($sig ne $expected_sig) { croak "get_signed_request returned bad sig"; }
    my $profile_id = $data->{'profile_id'};
    my $user_id = $data->{'user_id'};
    my $oauth_token = $data->{'oauth_token'};
    my $user = $data->{'user'};
    return ($user_id,$oauth_token,$profile_id);
}

1;
__END__

=head1 NAME

# Facebook API authentication using OAuth2

Net::Facebook::API - Perl extension for Facebook OAuth2 API

=head1 SYNOPSIS

use Net::Facebook::API;
### OO Interface
my $fb = Net::Facebook::API->new(
                                 client_id => 'your-application-id',
                                 client_secret => 'your-application-secret',
                                 http_request_method => 'post' # post or get
                                 );

my $auth_url = $fb->get_authorize_url(
    redirect_uri => 'http://www.yourdomain.com/yourapp',
    scope => 'offline_access'
    );


my $token = $fb->get_access_token(
    code => param('code'),
    redirect_uri => 'http://www.yourdomain.com/yourapp', # where to redirect after obtaining the code
    );

my ($user_id,$oauth_token,$profile_id) = get_signed_request(
    signed_request => param('signed_request'),
    client_id => 'your_application_id',
    client_secret => 'your_application_secret'
    ); ## get session information using facebook's signed requst param

my @res = $fb->get_newsfeed(access_token => $token);
my @res = $fb->get_wall(access_token => $token);
my @res = $fb->get_likes(access_token => $token);
my @res = $fb->get_movies(access_token => $token);
my @res = $fb->get_music(access_token => $token);
my @res = $fb->get_books(access_token => $token);
my @res = $fb->get_notes(access_token => $token);
my @res = $fb->get_photo_tags(access_token => $token);
my @res = $fb->get_photo_albums(access_token => $token);
my @res = $fb->get_video_tags(access_token => $token);
my @res = $fb->get_video_uploads(access_token => $token);
my @res = $fb->get_events(access_token => $token);
my @res = $fb->get_groups(access_token => $token);
my @res = $fb->get_checkins(access_token => $token);
my @res = $fb->get_me(access_token => $token);
my @res = $fb->get_accounts(access_token => $token);

#my @res = $fb->get_accounts(access_token => $token);
#for (0..length(@res[0]->{'data'})) {
#    my $page_name = @res[0]->{'data'}->[$_]->{'name'};
#    my $page_category = @res[0]->{'data'}->[$_]->{'category'};
#    my $page_id = @res[0]->{'data'}->[$_]->{'id'};
#    ...
#}
#OR
#use Data::Dumper;
#my $out = Dumper(@res);

=head1 DESCRIPTION
    This Perl extension allows communication with Facebook OAuth2 New API

=head1 SEE ALSO

See http://developers.facebook.com/docs/authentication/ for more details

=head1 AUTHOR

Asaf Klibansky, discobeta@gmail.com

=cut
