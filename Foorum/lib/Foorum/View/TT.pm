package Foorum::View::TT;

use strict;
use base 'Catalyst::View::TT';
#use Template::Constants qw( :debug );
#use NEXT;

__PACKAGE__->config(
	#DEBUG        => DEBUG_PARSER | DEBUG_PROVIDER,
	INCLUDE_PATH => [
              Foorum->path_to( 'templates' ), 
    ],
    WRAPPER      => 'wrapper.html',
);

1;
