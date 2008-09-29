package Catalyst::Plugin::CHI;

use warnings;
use strict;

use vars qw/$VERSION/;
$VERSION = '0.02';

use base 'Class::Data::Inheritable';
use CHI;

__PACKAGE__->mk_classdata('cache');

sub setup {
    my $self = shift;

    my $params = {};
    $params = $self->config->{CHI} if ( $self->config->{CHI} );
    $self->cache( CHI->new( %$params) );

    return $self->NEXT::setup(@_);
}

1;
__END__

=head1 NAME

Catalyst::Plugin::CHI - CHI wrap of Catalyst

=head1 SYNOPSIS

    use Catalyst qw[CHI];
    
    __PACKAGE__->config->{CHI} = {
        driver => 'File',
        cache_root => '/path/to/nowhere'
    };

    my $data;
    unless ( $data = $c->cache->get('data') ) {
        $data = MyApp::Model::Data->retrieve('data');
        $c->cache->set( 'data', $data );
    }
    $c->response->body($data);

=head1 CONFIGURATION

Mostly you need read the L<CHI>. something like follows are accpetable.

    __PACKAGE__->config->{CHI} = {
        driver => 'File',
        cache_root => '/path/to/nowhere'
    };
    
    __PACKAGE__->config->{CHI} = {
        driver     => 'FastMmap',
        root_dir   => '/path/to/root',
        cache_size => '1k'
    };
    
    __PACKAGE__->config->{CHI} = {
        driver  => 'Memcached',
        servers => [ "10.0.0.15:11211", "10.0.0.15:11212" ]
    };
    
    __PACKAGE__->config->{CHI} = {
        driver => 'Multilevel',
        subcaches => [
            { driver => 'Memory' },
            {
                driver  => 'Memcached',
                servers => [ "10.0.0.15:11211", "10.0.0.15:11212" ]
            }
        ],
    };

=head1 METHODS

the C<$c->cache> are the same as L<CHI>.

=head1 AUTHOR

Fayland Lam, C<< <fayland at gmail.com> >>

=head1 COPYRIGHT & LICENSE

Copyright 2008 Fayland Lam, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.
