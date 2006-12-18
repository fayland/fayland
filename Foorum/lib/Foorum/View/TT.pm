package Foorum::View::TT;

use strict;
use base 'Catalyst::View::TT';
use Template::Stash::XS;
use File::Spec;
#use Template::Constants qw( :debug );
use NEXT;
use Email::Obfuscate qw(obfuscate_email_address);

my $tmpdir = File::Spec->tmpdir();

__PACKAGE__->config(
    #DEBUG        => DEBUG_PARSER | DEBUG_PROVIDER,
    INCLUDE_PATH => [
        Foorum->path_to( 'templates' ), 
    ],
    COMPILE_DIR => $tmpdir . "/ttcache/$<",
	COMPILE_EXT => '.ttp1', 
	STASH       => Template::Stash::XS->new,
    FILTERS      => {
        'email_obfuscate' => sub { obfuscate_email_address(shift) },
    }
);

sub render {
    my $self  = shift;
    my ( $c, $template, $args ) = @_;
    
    # view Catalyst::View::TT for more details
    my $vars = { 
        (ref $args eq 'HASH' ? %$args : %{ $c->stash() }),
    };

    if ($vars->{no_wrapper}) {
        $self->template->service->{WRAPPER} = [];
    } else {
        $self->template->service->{WRAPPER} = ['wrapper.html'];
    }

    $self->NEXT::render(@_);
}


=pod

=head2 AUTHOR

Fayland Lam <fayland@gmail.com>

=cut

1;
