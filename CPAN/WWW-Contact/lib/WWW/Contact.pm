package WWW::Contact;

use vars qw/$VERSION $AUTHORITY/;
use Moose;
use Moose::Util::TypeConstraints;

$VERSION   = '0.01';
$AUTHORITY = 'cpan:FAYLAND';

has 'errstr'   => ( is => 'rw', isa => 'Maybe[Str]' );
has 'supplier' => ( is => 'rw', isa => 'Str' );
has 'custom_supplier_code' => ( is => 'rw', isa => 'CodeRef', default => sub { sub {} } );

sub get_contacts {
    my $self = shift;
    my ( $email, $password ) = @_;
    
    unless ( $email and $password ) {
        $self->errstr('Both email and password are required.');
        return;
    }
    
    unless ( $email =~ m/^(.+)\@(([^.]+)\.(.+))$/ ) {
        $self->errstr('You must supply full email address.');
        return;
    }
    
    my ( $username, $postfix ) = ( lc($1), lc($2) );
    
    # get supplier module
    unless ($self->supplier) {
        $self->get_supplier_by_email($email) or $self->custom_supplier_code($email);
        unless ($self->supplier) {
            $self->errstr("$email is not supported yet.");
            return;
        }
    }
    
    my $module = 'WWW::Contact::' . $self->supplier;
    eval("use $module;");
    if ($@) {
        $self->errstr($@);
        return;
    }
    
    my $wc = new $module;
    
    # reset
    $self->errstr(undef);
    
    my $contacts = $wc->get_contacts( $email, $password );

    if ( $wc->errstr ) {
        $self->errstr( $wc->errstr );
        return;
    } else {
        return wantarray ? @$contacts : $contacts;
    }
}

sub get_supplier_by_email {
    my ($self, $email) = @_;
    
    if ($email =~ /[\@\.]yahoo\./) {
        $self->supplier('Yahoo');
    } elsif ($email =~ /\@gmail\.com$/) {
        $self->supplier('Gmail');
    }
    
    return $self->supplier ? 1 : 0;
}

no Moose;
no Moose::Util::TypeConstraints;

1;
__END__

=head1 NAME

WWW::Contact - The great new WWW::Contact!

=head1 SYNOPSIS

Quick summary of what the module does.

Perhaps a little code snippet.

    use WWW::Contact;

    my $wc = WWW::Contact->new();
    ...



=head1 AUTHOR

Fayland Lam, C<< <fayland at gmail.com> >>

=head1 COPYRIGHT & LICENSE

Copyright 2008 Fayland Lam, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut
