package WWW::Contact::Unknown;

use Moose;
with 'WWW::Contact::Base';

sub get_contacts {
    my ($self, $email, $password) = @_;
    
    if ($email eq 'a@a.com' and $password eq 'b') {
        $self->errstr('error!');
        return;
    }
    
    return ( {
        email => 'b@b.com',
        name => 'b',
    }, {
        email => 'c@c.com',
        name => 'c'
    } );
}

1;