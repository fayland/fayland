package Foorum::View::SimpleTT;

use strict;
use base 'Catalyst::View::TT';
#use Template::Constants qw( :debug );
#use NEXT;

__PACKAGE__->config(
	#DEBUG        => DEBUG_PARSER | DEBUG_PROVIDER,
	INCLUDE_PATH => [
              Foorum->path_to( 'templates' ), 
    ],
    WRAPPER      => 'simple_wrapper.html',
);

1;
