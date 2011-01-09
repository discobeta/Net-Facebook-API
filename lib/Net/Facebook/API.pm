package Net::Facebook::API;

use 5.008005;
use strict;
use warnings;
use LWP::UserAgent;
use URI::Escape;
use MIME::Base64::URLSafe;
use Digest::SHA qw(hmac_sha256);
use JSON::XS;

require Exporter;
use AutoLoader qw(AUTOLOAD);

our @ISA = qw(Exporter);

# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.

# This allows declaration	use Net::Facebook::API ':all';
# If you do not need this, moving things directly into @EXPORT or @EXPORT_OK
# will save memory.
our %EXPORT_TAGS = ( 'all' => [ qw() ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw();

our $VERSION = '0.06';


# Preloaded methods go here.

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

sub get_url {
    my ($self,%opt) = @_;
    if (!$opt{http_request_method} && !$self->{options}->{http_request_method}) { die "get_url requires http_request_method to be set"; }
    if (!$opt{url} && !$self->{options}->{url}) { die "get_url requires url to be set"; }    
    my $http_request_method;
    if ($opt{http_request_method}) { $http_request_method = $opt{http_request_method}; } else { $http_request_method = $self->{options}->{http_request_method}; }
    my $res = LWP::UserAgent->new->$http_request_method($opt{url},%opt)->as_string;
    $res =~ m/\n\n(.+)/;
    return $1;
}

sub get_api_to_scalar {
    my ($self,%opt) = @_;
    if (!%opt->{access_token}) { die "get_api_to_scalar requires access_token to be set"; }
    if (!%opt->{url}) { die "get_api_to_scalar requires url to be set"; }
    my $access_token;
    if (%opt->{access_token}) { $access_token = %opt->{access_token}; } else { $access_token = %opt->{access_token}; }
    my $info = LWP::UserAgent->new->get(
					 %opt->{url}."?access_token=".%opt->{access_token},
					 %opt)->as_string;
    $info =~ m/\n\n(.+)/;
    my @hash = decode_json $1;
    return @hash;
}

sub get_friends { 
    my ($opt) = @_;
    return Net::Facebook::API->get_api_to_scalar(
						 access_token => $opt->{access_token},
						 url => 'https://graph.facebook.com/me/friends'
						 ); 
}

sub get_newsfeed { my ($opt) = @_; return Net::Facebook::API->get_api_to_scalar(access_token => $opt->{access_token}, url => 'https://graph.facebook.com/me/home'); }
sub get_wall { my ($self,%opt) = @_; return Net::Facebook::API->get_api_to_scalar(access_token => %opt->{access_token}, url => 'https://graph.facebook.com/me/feed'); }
sub get_likes { my ($opt) = @_; return Net::Facebook::API->get_api_to_scalar(access_token => $opt->{access_token}, url => 'https://graph.facebook.com/me/likes'); }
sub get_movies { my ($opt) = @_; return Net::Facebook::API->get_api_to_scalar(access_token => $opt->{access_token}, url => 'https://graph.facebook.com/me/movies'); }
sub get_music { my ($opt) = @_; return Net::Facebook::API->get_api_to_scalar(access_token => $opt->{access_token}, url => 'https://graph.facebook.com/me/music'); }
sub get_books { my ($opt) = @_; return Net::Facebook::API->get_api_to_scalar(access_token => $opt->{access_token}, url => 'https://graph.facebook.com/me/books'); }
sub get_notes { my ($opt) = @_; return Net::Facebook::API->get_api_to_scalar(access_token => $opt->{access_token}, url => 'https://graph.facebook.com/me/notes'); }
sub get_photo_tags { my ($opt) = @_; return Net::Facebook::API->get_api_to_scalar(access_token => $opt->{access_token}, url => 'https://graph.facebook.com/me/photos'); }
sub get_photo_albums { my ($opt) = @_; return Net::Facebook::API->get_api_to_scalar(access_token => $opt->{access_token}, url => 'https://graph.facebook.com/me/albums'); }
sub get_video_tags { my ($opt) = @_; return Net::Facebook::API->get_api_to_scalar(access_token => $opt->{access_token}, url => 'https://graph.facebook.com/me/videos'); }
sub get_video_uploads { my ($opt) = @_; return Net::Facebook::API->get_api_to_scalar(access_token => $opt->{access_token}, url => 'https://graph.facebook.com/me/videos/uploaded'); }
sub get_events { my ($opt) = @_; return Net::Facebook::API->get_api_to_scalar(access_token => $opt->{access_token}, url => 'https://graph.facebook.com/me/events'); }
sub get_groups { my ($opt) = @_; return Net::Facebook::API->get_api_to_scalar(access_token => $opt->{access_token}, url => 'https://graph.facebook.com/me/groups'); }
sub get_checkins { my ($opt) = @_; return Net::Facebook::API->get_api_to_scalar(access_token => $opt->{access_token}, url => 'https://graph.facebook.com/me/checkins'); }

sub get_authorize_url {
    my ($self,%opt) = @_;
    if (!$opt{authorize_url} && !$self->{options}->{authorize_url}) { die "get_authorize_url requires authorize_url to be set"; }
    my $auth_url;
    if ($opt{authorize_url}) { $auth_url = $opt{authorize_url}."?"; } else { $auth_url = $self->{options}->{authorize_url}."?"; }
    for (qw(redirect_uri client_id)) {
	if (!$opt{$_} && !$self->{options}->{$_}) { die "get_authorize_url requires $_ to be set"; }
	if ($opt{$_}) { $auth_url .= $_."=".uri_escape($opt{$_}); } else { $auth_url .= $_."=".uri_escape($self->{options}->{$_}); }
	$auth_url .= "&";
    }
    for (qw(scope display)) {
	if ($opt{$_} || $self->{options}->{$_}) {
	    if ($opt{$_}) { $auth_url .= $_."=".uri_escape($opt{$_}); } else { $auth_url .= $_."=".uri_escape($self->{options}->{$_}); }
	    $auth_url .= "&";
	}
    }
    return $auth_url;
}

sub get_access_token {
    my ($self,%opt) = @_;
    my $token_url;
    if ($opt{access_token_url}) { $token_url = $opt{access_token_url}."?"; } else { $token_url = $self->{options}->{access_token_url}."?"; }
    for (qw(code client_id client_secret redirect_uri)) {
	if (!$opt{$_} && !$self->{options}->{$_}) { die "get_access_token requires $_ to be set"; }
	if ($opt{$_}) { $token_url .= $_."=".uri_escape($opt{$_}); } else { $token_url .= $_."=".uri_escape($self->{options}->{$_}); }
	$token_url .= "&";
    }
    my $token = LWP::UserAgent->new->post($token_url,%opt)->as_string;
    $token =~ m/access_token=(.+)/;
    if ($token =~ /OAuthException/) { 
	$token =~ m/message":"(.+)"/; #"
	die "get_access_token returned OAuthException $1"; 
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
    if (uc($data->{'algorithm'}) ne "HMAC-SHA256") { die "get_signed_request returned bad algorithm"; }
    my $expected_sig = hmac_sha256($payload, $client_secret);
    if ($sig ne $expected_sig) { die "get_signed_request returned bad sig"; }
    my $profile_id = $data->{'profile_id'};
    my $user_id = $data->{'user_id'};
    my $oauth_token = $data->{'oauth_token'};
    my $user = $data->{'user'};
    return ($user_id,$oauth_token,$profile_id);
}


# Autoload methods go after =cut, and are processed by the autosplit program.

1;
__END__
# Below is stub documentation for your module. You'd better edit it!

=head1 NAME

# Facebook API authentication using OAuth2

Net::Facebook::API - Perl extension for Facebook OAuth2 API

=head1 SYNOPSIS

use Net::Facebook::API;
use CGI qw(:standard);
use strict;

my $cgi = CGI->new;
my $r = shift;
my $token;
my $fb = Net::Facebook::API->new(
                                 client_id => 'your-application-id',
                                 client_secret => 'your-application-secret',
                                 http_request_method => 'post' # post or get
                                 );

if (!param('code')) {
    my $auth_url = $fb->get_authorize_url(
                                          redirect_uri => 'http://www.yourdomain.com/yourapp',
                                          scope => 'offline_access'
                                          );
    print $cgi->redirect($auth_url);
    exit();
}

if (param('code')) {
    $token = $fb->get_access_token(
                                   code => param('code'),
                                   redirect_uri => 'http://www.yourdomain.com/yourapp', # where to redirect after obtaining the code
                                   );
}
if (!$token) {
    print $cgi->redirect(
                         $fb->get_authorize_url(
                                                redirect_uri => 'http://www.yourdomain.com/yourapp',
                                                scope => 'offline_access,publish_stream' # scope of permissions, see http://developers.facebook.com/docs/authentication/permissions
                                                )
                         )};

### store your access_token in a cookie
### write your code here...

my @res = $fb->get_newsfeed(access_token => $token);
#my @res = $fb->get_wall(access_token => $token);
#my @res = $fb->get_likes(access_token => $token);
#my @res = $fb->get_movies(access_token => $token);
#my @res = $fb->get_music(access_token => $token);
#my @res = $fb->get_books(access_token => $token);
#my @res = $fb->get_notes(access_token => $token);
#my @res = $fb->get_photo_tags(access_token => $token);
#my @res = $fb->get_photo_albums(access_token => $token);
#my @res = $fb->get_video_tags(access_token => $token);
#my @res = $fb->get_video_uploads(access_token => $token);
#my @res = $fb->get_events(access_token => $token);
#my @res = $fb->get_groups(access_token => $token);
#my @res = $fb->get_checkins(access_token => $token);

use Data::Dumper;
my $out = Dumper(@res);

$r->content_type("text/html; charset=utf-8");
$r->print("<pre>$out</pre>");

=head1 SEE ALSO

See http://developers.facebook.com/docs/authentication/ for more details

=head1 AUTHOR

Asaf Klibansky, E<lt>asaf@sortprice.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 by Asaf Klibansky

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.5 or,
at your option, any later version of Perl 5 you may have available.


=cut