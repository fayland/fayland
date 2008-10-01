package WWW::Contact::Gmail;

use Moose;
with 'WWW::Contact::Base';

use HTML::TokeParser::Simple;

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
    $ua->follow_link( url => '?v=cl&pnl=a' );
    
    $content = $ua->content();
    @contacts = $self->get_contacts_from_html($content);
    
    return wantarray ? @contacts : \@contacts;
}

sub get_contacts_from_html {
    my ($self, $content) = @_;;
    
    my (@names, @emails);
    
    my $start = 0;
    my $p = HTML::TokeParser::Simple->new( string => $content );
    while ( my $token = $p->get_token ) {
        if ( my $tag = $token->get_tag ) {
            # start with input checbox and <input type="checkbox" name="c"
            # end with  /table
            if ($tag eq 'input') {
                my $type = $token->get_attr('type');
                my $name = $token->get_attr('name');
                if ( $type and $type eq 'checkbox' and $name and $name eq 'c' ) {
                    $start = 1;
                }
            }
            $start = 0 if ($tag eq 'table');
            if ($start) {
                if ($tag eq 'b' and $token->is_start_tag) {
                    my $name = $p->peek(1);
                    push @names, $name;
                }
            }   
        }
        if ($start) {
            my $text = $token->as_is;
            if ($text =~ /(\S+\@\S+)/) {
                push @emails, $1;
            }
        }
    }
    
    my @contacts;
    foreach my $i (0 .. $#emails) {
        push @contacts, {
            name  => $names[$i],
            email => $emails[$i]
        };
    }
    
    return @contacts;
}

no Moose;

1;
__END__
