package Catalyst::Plugin::HTTP::Session;

use Moose;
use Class::MOP ();
use HTTP::Session;
use Object::Signature   ();
use CGI;

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:FAYLAND';

with 'MooseX::Emulate::Class::Accessor::Fast';

__PACKAGE__->mk_accessors(qw/
        _session
        _session_obj
        _session_data_sig
        _tried_loading_session_data
    /
);


sub session {
    my $c = shift;

    $c->_session || $c->_load_session;
}

sub _load_session {
    my $c = shift;
    
    return $c->_session if $c->_tried_loading_session_data;
    $c->_tried_loading_session_data(1);

    my $cfg = $c->config->{http_session};
    my $store_class = $cfg->{store_class};
    my $state_class = $cfg->{state_class};
    Class::MOP::load_class($store_class);
    Class::MOP::load_class($state_class);
    my $session = HTTP::Session->new(
        store   => $store_class->new(
            $cfg->{store} || {}
        ),
        state   => $state_class->new(
            $cfg->{state} || {}
        ),
        request => new CGI( $c->req->params ),
    );
    $c->_session_obj( $session );
    my $session_data = $session->as_hashref || {};
    $c->_session_data_sig( Object::Signature::signature($session_data) );
    $c->_session( $session_data );

    return $session_data;
}

sub finalize_headers {
    my $c = shift;

    # fix cookie before we send headers
    $c->_session_obj->response_filter( $c->res );

    return $c->NEXT::finalize_headers(@_);
}

sub finalize {
    my $c = shift;
    my $ret = $c->NEXT::finalize(@_);
    
    # save session
    my $session = $c->_session;
    if ( Object::Signature::signature($session) ne
            $c->_session_data_sig )
        {
        my $session_obj = $c->_session_obj;
        $session_obj->_data( $session );
        $session_obj->is_changed(1);
    }

    # clear data for every request
    $c->_session(undef);
    $c->_tried_loading_session_data(undef);
    $c->_session_obj(undef);
    
    return $ret;
}


no Moose;

1;
__END__

=head1 NAME

Catalyst::Plugin::HTTP::Session - The great new Catalyst::Plugin::HTTP::Session!

=head1 SYNOPSIS

    use Catalyst::Plugin::HTTP::Session;

    my $foo = Catalyst::Plugin::HTTP::Session->new();
    ...


=head1 AUTHOR

Fayland Lam, C<< <fayland at gmail.com> >>

=head1 COPYRIGHT & LICENSE

Copyright 2008 Fayland Lam, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut
