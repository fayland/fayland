package Foorum::Controller::Location;

use strict;
use warnings;
use base 'Catalyst::Controller';
use Foorum::Utils qw/get_page_no_from_url/;
use Locale::Country::Multilingual;
use Encode qw/decode/;

sub country : PathPart('country') Chained('/') CaptureArgs(1) {
    my ( $self, $c, $country_code ) = @_;

    my $lcm = Locale::Country::Multilingual->new();
    $lcm->set_lang($c->stash->{lang});
    my $country_name = decode('utf8', $lcm->code2country($country_code));
    unless ($country_name) {
        $c->detach('/print_error', [ 'ERROR_WRONG_VISIT' ]);
    }
    
    my $forum = $c->forward('/get/forum', [ $country_code, { forum_type => 'country' } ]);
    
    $c->stash->{country} = { code => $country_code, name => $country_name };
}

sub country_home : PathPart('') Chained('country') Args(0) {
    my ($self, $c) = @_;

    my @users = $c->model('DBIC::User')->search( {
        country => $c->stash->{country}->{code},
    }, {
        order_by => \'last_post_id desc',
        rows => 10,
        page => 1,
        columns => ['username', 'nickname', 'user_id'],
    } )->all;
    
    my $forum = $c->forward('/get/forum', [ $c->stash->{country}->{code}, { forum_type => 'country' } ]);

    $c->stash->{members}  = \@users;
    $c->stash->{template} = 'location/country.html';
}

=pod

=head2 AUTHOR

Fayland Lam <fayland@gmail.com>

=cut

1;
