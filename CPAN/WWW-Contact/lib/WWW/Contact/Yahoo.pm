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
    $self->get('https://login.yahoo.com/config/login_verify2?&.src=ym');
    $self->submit_form(
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

    $self->get('http://address.mail.yahoo.com/');
    $ua->follow_link( url_regex => qr/import_export/i );
    
    ##### detect the export form, the last form
    my $form_number = 3;
    while ( $form_number > 0 && !$self->{ua}->form_number($form_number) ) {
        $form_number--;
    }
    #####

    eval {
        $self->submit_form(
            form_number => $form_number,
            button      => 'submit[action_export_yahoo]',
        );
    };
    
    $content = $ua->content();
    my $i;
    while ( $content
        =~ /^\"(.*?)\"\,\".*?\"\,\"(.*?)\"\,\".*?\"\,\"(.*?)\"\,\".*?\"\,\".*?\"\,\"(.*?)\"/mg
        )
    {
        $i++;
        next if ( $i == 1 );    # skip the first line.
        next unless ( $3 or $4 );
        my $email = $3 || $4 . '@yahoo.com';
        my $name = ( $1 or $2 ) ? "$1 $2" : $4;
        $_ = {
            name       => $name,
            email      => $email,
        };
        push @contacts, $_;
    }

    return wantarray ? @contacts : \@contacts;
}

no Moose;

1;
__END__
