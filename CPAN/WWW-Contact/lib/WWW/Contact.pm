package WWW::Contact;

use Moose;
use Moose::Util::TypeConstraints;

our $VERSION   = '0.03';
our $AUTHORITY = 'cpan:FAYLAND';

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

sub pre_supplier { inner() }

sub get_supplier_by_email {
    my ($self, $email) = @_;
    
    $self->pre_supplier();
    
    my ($username, $domain) = split('@', $email);
    # @yahoo.com @yahoo.XX @ymail.com @rocketmail.com
    if ($email =~ /[\@\.]yahoo\./ or $domain eq 'ymail.com' or $email eq 'rocketmail.com' ) {
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

WWW::Contact - Get contacts/addressbook from Web

=head1 SYNOPSIS

    use WWW::Contact;
    
    my $wc       = WWW::Contact->new();
    my @contacts = $wc->get_contacts('fayland@gmail.com', 'password');
    my $errstr   = $wc->errstr;
    if ($errstr) {
        die $errstr; # like 'Wrong Password'
    } else {
        print Dumper(\@contacts);
    }

=head1 DESCRIPTION

Get Contacts/AddressBook from public websites.

=head1 SUPPORTED EMAIL SUPPLIER

=over 4

=item Gmail

=item Yahoo! Mail

=back

=head1 HOW TO WRITE MY OWN MODULE

please read L<WWW::Contact::Base> and examples: L<WWW::Contact::Yahoo> and L<WWW::Contact::Gmail>

Assuming we write a custom module as WWW::Contact::Unknown

    package WWW::Contact::Unknown;
    
    use Moose;
    extends 'WWW::Contact::Base';
    
    sub get_contacts {
        my ($self, $email, $password) = @_;
        
        # reset
        $self->errstr(undef);
        
        if ($email eq 'a@a.com' and $password ne 'a') {
            $self->errstr('Wrong Password');
            return;
        }
        
        my @contacts = ( {
            email => 'b@b.com',
            name => 'b',
        }, {
            email => 'c@c.com',
            name => 'c'
        } );
        return wantarray ? @contacts : \@contacts;
    }
    
    1;

We can use it within WWW::Contact

    my $wc = new WWW::Contact;
    $wc->supplier('Unknown'); # it will eval use WWW::Contact::Unknown when get_contacts
    
    my @contacts = $wc->get_contacts('a@a.com', 'b');
    my $errstr = $wc->errstr;

=head1 SEE ALSO

L<WWW::Contact::Gmail>, L<WWW::Contact::Yahoo>, L<WWW::Mechanize>, L<Moose>

=head1 AUTHOR

Fayland Lam, C<< <fayland at gmail.com> >>

=head1 COPYRIGHT & LICENSE

Copyright 2008 Fayland Lam, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut
