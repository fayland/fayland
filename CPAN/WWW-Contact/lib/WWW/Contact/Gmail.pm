package WWW::Contact::Gmail;

use Moose;
with 'WWW::Contact::Base';

sub get_contacts {
    my ($self, $email, $password) = @_;
    
    # reset
    $self->errstr(undef);
    my @contacts;
    
    my $ua = $self->ua;
    $self->debug("start get_contacts from gmail");
    
    # to form
    $ua->get('https://mail.google.com/mail/');
    $ua->submit_form(
        form_number => 1,
        fields      => {
            Email  => $email,
            Passwd => $password,
        }
    );
    my $content = $ua->content();
    if ($content =~ /=[\'\"]errormsg/) {
        $self->errstr('Wrong Password');
        return;
    }
    
    $self->debug('Login OK');
    # use basic HTML
    $ua->get('https://mail.google.com/mail/?ui=html&zy=a');
    $ua->follow_link( url => '?v=cl' );
    
    
    return wantarray ? @contacts : \@contacts;
}

no Moose;

1;
__END__
