package WWW::Contact::Yahoo;

use Moose;
with 'WWW::Contact::Base';

sub get_contacts {
    my ($self, $email, $password) = @_;

    # reset
    $self->errstr(undef);
    my @contacts;
    
    my $ua = $self->ua;
    $self->debug("start get_contacts from Yahoo!");
    
    # to form
    my $resp = $ua->get('https://login.yahoo.com/config/login_verify2?&.src=ym');
    unless ( $resp->is_success ) {
        $self->errstr( $resp->as_string() );
        return;
    }
    
    $ua->submit_form(
        form_name => 'login_form',
        fields    => {
            login  => $email,
            passwd => $password,
        },
    );
    my $content = $ua->content();
    if ($content =~ /=[\'\"]yregertxt/) {
        $self->errstr('Wrong Password');
        return;
    }
    
    $self->debug('Login OK');

    $ua->get('http://address.mail.yahoo.com/');
    $ua->follow_link( url_regex => qr/import_export/i );
    
    ##### detect the export form, the last form
    my $form_number = 3;
    while ( $form_number > 0 && !$self->{ua}->form_number($form_number) ) {
        $form_number--;
    }
    #####

    eval {
        $self->{ua}->submit_form(
            form_number => $form_number,
            button      => 'submit[action_export_outlook]',
        );
    };
    
    $content = $ua->content();
    @contacts = $self->get_contacts_from_outlook_csv($content);
    
    return wantarray ? @contacts : \@contacts;
}

no Moose;

1;
__END__
