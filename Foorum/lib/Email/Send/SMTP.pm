package Email::Send::SMTP;
use strict;

use vars qw[$SMTP $VERSION];
use Email::Address;
use Return::Value;

$VERSION   = '2.04';

sub is_available {
    my ($class, %args) = @_;
    my $success = 1;
    $success = eval { require Net::SMTP };
    $success = eval { require Net::SMTP::SSL } if $args{ssl};
    return   $success
           ? success
           : failure $@;
}

sub send {
    my ($class, $message, @args) = @_;
    require Net::SMTP;
    my %args;
    if ( @_ > 1 ) {
        if ( @args % 2 ) {
            my $host = shift @args;
            %args = @args;
            $args{Host} = $host;
        } else {
            %args = @args;
        }

        my $host = delete($args{Host}) || 'localhost';
        if ( $args{ssl} ) {
            require Net::SMTP::SSL;
            $SMTP->quit if $SMTP;
            $SMTP = Net::SMTP::SSL->new($host, %args);
            return failure "Couldn't connect to $host" unless $SMTP;
        } elsif ( $args{tls} ) {
            require Net::SMTP::TLS;
            $SMTP->quit if $SMTP;
            $SMTP = Net::SMTP::TLS->new($host, %args);
            return failure "Couldn't connect to $host" unless $SMTP;
        } else {
            $SMTP->quit if $SMTP;
            $SMTP = Net::SMTP->new($host, %args);
            return failure "Couldn't connect to $host" unless $SMTP;
        }
        
        my ($user, $pass)
          = @args{qw[username password]};
        if ( $user ) {
            $SMTP->auth($user, $pass)
              or return failure "Couldn't authenticate '$user:...'";
        }
    }
    
    my @bad;
    my @to;
    eval {
        my $from =
          (Email::Address->parse($message->header('From')))[0]->address;
        if ( $args{tls} ) {
            $SMTP->mail($from);
        } else {
            $SMTP->mail($from) or return failure "FROM: <$from> denied";
        }

        @to = map {
                   map { $_->address }
                       Email::Address->parse($message->header($_))
                  } qw[To Cc Bcc];
        my @ok;
        if ( $args{tls} ) {
            @ok = $SMTP->to($to[0]);
        } else {
            @ok = $SMTP->to(@to, { SkipBad => 1 });
        }

        if ( @to != @ok ) {
            my %to; @to{@to} = (1) x @to;
            delete @to{@ok};
            @bad = keys %to;
        }
    };
    return failure $@ if $@;

    return failure "No valid recipients" if (@bad == @to and ! $args{tls});

    if ( $args{tls} ) {
        $SMTP->data;
        $SMTP->datasend( $message->as_string );
        $SMTP->dataend;
    } else {
        return failure "Can't send data"
           unless $SMTP->data( $message->as_string );
    }

    return success "Message sent", prop => {
        bad => [ @bad ],
    };
}

sub DESTROY {
    $SMTP->quit if $SMTP;
}

1;

__END__

=head1 NAME

Email::Send::SMTP - Send Messages using SMTP

=head1 SYNOPSIS

  use Email::Send;

  my $mailer = Email::Send->new({mailer => 'SMTP'});
  
  $mailer->mailer_args([Host => 'smtp.example.com:465', ssl => 1])
    if $USE_SSL;
  
  $mailer->send($message);

=head1 DESCRIPTION

This mailer for C<Email::Send> uses C<Net::SMTP> to send a message with
an SMTP server. The first invocation of C<send> requires an SMTP server
arguments. Subsequent calls will remember the the first setting until
it is reset.

Any arguments passed to C<send> will be passed to C<< Net::SMTP->new() >>,
with some exceptions. C<username> and C<password>, if passed, are
used to invoke C<< Net::SMTP->auth() >> for SASL authentication support.
C<ssl>, if set to true, turns on SSL support by using C<Net::SMTP::SSL>.

SMTP can fail for a number of reasons. All return values from this
package are true or false. If false, sending has failed. If true,
send succeeded. The return values are C<Return::Value> objects, however,
and contain more information on just what went wrong.

Here is an example of dealing with failure.

  my $return = send SMTP => $message, 'localhost';
  
  die "$return" if ! $return;

The stringified version of the return value will have the text of the
error. In a conditional, a failure will evaluate to false.

Here's an example of dealing with success. It is the case that some
email addresses may not succeed but others will. In this case, the
return value's C<bad> property is set to a list of bad addresses.

  my $return = send SMTP => $message, 'localhost';

  if ( $return ) {
      my @bad = @{ $return->prop('bad') };
      warn "Failed to send to: " . join ', ', @bad
        if @bad;
  }

For more information on these return values, see L<Return::Value>.

=head1 SEE ALSO

L<Email::Send>,
L<Net::SMTP>,
L<Net::SMTP::SSL>,
L<Email::Address>,
L<Return::Value>,
L<perl>.

=head1 AUTHOR

Current maintainer: Ricardo SIGNES, <F<rjbs@cpan.org>>.

Original author: Casey West, <F<casey@geeknest.com>>.

=head1 COPYRIGHT

  Copyright (c) 2004 Casey West.  All rights reserved.
  This module is free software; you can redistribute it and/or modify it
  under the same terms as Perl itself.

=cut