package WWW::Contact::Gmail;

use Moose;
with 'WWW::Contact::Base';

use 

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
    while (
        $content =~ m/
			,\[".*?"
			, "([^"]+)"		# 1 id
			,"([^"]*)"		# 2 name
			,"([^"]*)"		# 3
			,"([^"]+)"		# 4 email
			,"([^"]*)"		# 5 notes
			/xg
    ) {
        push @contacts, {
            name  => $2,
            email => $4,
        };
    }
    
    open(my $fh, '>', 'E:\a.txt');
    print $fh $content;
    close($fh);
    
    return wantarray ? @contacts : \@contacts;
}

sub get_contacts_from_html {
    my ($content) = @_;;
    
    my $return_things;
    my (@names, @emails);
    
    my $start = 0; my $mark;
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
                if ($tag eq 'b') {
                    my $name = $p->peek(1);
                    push @names, $name if ($name =~ /\S/);
                }
            }   
        }
        if ($start) {
            my $text = $token->as_is;
            $return_things .= $text;
            if ($text =~ /(\S+\@\S+)/) {
                push @emails, $1;
            }
        }
    }
    
    # <input type="checkbox" name="c" value="2d30c9900d9f6538"> </td> <td width="28%"> <b>fayland</b> </td> <td width="71%"> fayland@gmail.com &nbsp; </td> <tr> <td> <input type="checkbox" name="c" value="49c06ff88f28abd8"> </td> <td> <b>fayland zorpia</b> </td> <td> fayland.lam@zorpia.com &nbsp; </td> <tr> <td colspan="5" height="75" bgcolor="#ffffff">&nbsp;
    
    
    
    return ($return_things, \@names, \@emails);
}

no Moose;

1;
__END__
