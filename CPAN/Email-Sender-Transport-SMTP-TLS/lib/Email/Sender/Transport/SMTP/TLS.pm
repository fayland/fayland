package Email::Sender::Transport::SMTP::TLS;

use warnings;
use strict;

our $VERSION = '0.02';

use Moose;
extends 'Email::Sender::Transport';

use Net::SMTP::TLS;
use Email::Sender::Failure::Multi;
use Email::Sender::Success::Partial;
use Email::Sender::Util;

has host => (is => 'ro', isa => 'Str', default => 'localhost');
has port => (is => 'ro', isa => 'Int', default => 587 );
has username => (is => 'ro', isa => 'Str', required => 1);
has password => (is => 'ro', isa => 'Str', required => 1);
has allow_partial_success => (is => 'ro', isa => 'Bool', default => 0);
has helo      => (is => 'ro', isa => 'Str'); # default to hostname_long

# From http://search.cpan.org/src/RJBS/Email-Sender-0.000/lib/Email/Sender/Transport/SMTP.pm
## I am basically -sure- that this is wrong, but sending hundreds of millions of
## messages has shown that it is right enough.  I will try to make it textbook
## later. -- rjbs, 2008-12-05
sub _quoteaddr {
    my $addr       = shift;
    my @localparts = split /\@/, $addr;
    my $domain     = pop @localparts;
    my $localpart  = join q{@}, @localparts;

    # this is probably a little too paranoid
    return $addr unless $localpart =~ /[^\w.+-]/ or $localpart =~ /^\./;
    return join q{@}, qq("$localpart"), $domain;
}

sub _smtp_client {
    my ($self) = @_;

    my $smtp;
    eval {
        $smtp = Net::SMTP::TLS->new(
            $self->host,
            Port => $self->port,
            User => $self->username,
            Password => $self->password,
            $self->helo ? (Hello => $self->helo) : (),
        );
    };

    $self->_throw($@) if $@;
    $self->_throw("unable to establish SMTP connection") unless $smtp;

    return $smtp;
}

sub _throw {
    my ($self, @rest) = @_;
    Email::Sender::Util->_failure(@rest)->throw;
}

sub send_email {
    my ($self, $email, $env) = @_;

    Email::Sender::Failure->throw("no valid addresses in recipient list")
        unless my @to = grep { defined and length } @{ $env->{to} };

    my $smtp = $self->_smtp_client;

    my $FAULT = sub { $self->_throw($_[0], $smtp); };

    eval {
        $smtp->mail(_quoteaddr($env->{from}));
    };
    $FAULT->("$env->{from} failed after MAIL FROM: $@") if $@;

    my @failures;
    my @ok_rcpts;
  
    for my $addr (@to) {
        eval {
            $smtp->to(_quoteaddr($addr));
        };
        unless ( $@ ) {
            push @ok_rcpts, $addr;
        } else {
            # my ($self, $error, $smtp, $error_class, @rest) = @_;
            push @failures, Email::Sender::Util->_failure(
                undef,
                $smtp,
                recipients => [ $addr ],
            );
        }
    }

    if (
        @failures
        and ((@ok_rcpts == 0) or (! $self->allow_partial_success))
    ) {
        $failures[0]->throw if @failures == 1;

        my $message = sprintf '%s recipients were rejected during RCPT',
            @ok_rcpts ? 'some' : 'all';

        Email::Sender::Failure::Multi->throw(
            message  => $message,
            failures => \@failures,
        );
    }

    eval {
        $smtp->data();
        $smtp->datasend( $email->as_string );
        $smtp->dataend;
        $smtp->quit;
    };
    # ignore $@

  # XXX: We must report partial success (failures) if applicable.
    return $self->success unless @failures;
    return Email::Sender::Success::Partial->new({
        failure => Email::Sender::Failure::Multi->new({
          message  => 'some recipients were rejected during RCPT',
          failures => \@failures
        }),
    });
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

__END__

=head1 NAME

Email::Sender::Transport::SMTP::TLS - Email::Sender with L<Net::SMTP::TLS> (Eg. Gmail)

=head1 SYNOPSIS

    use Email::Sender::Transport::SMTP::TLS;

    my $sender = Email::Sender::Transport::SMTP::TLS->new(
        host => 'smtp.gmail.com',
        port => 587,
        username => 'username@gmail.com',
        password => 'password',
        helo => 'fayland.org',
    );
    
    #   my $message = Mail::Message->read($rfc822)
    #         || Email::Simple->new($rfc822)
    #         || Mail::Internet->new([split /\n/, $rfc822])
    #         || ...
    #         || $rfc822;
    # read L<Email::Abstract> for more details

    use Email::Simple::Creator; # or other Email::
    my $message = Email::Simple->create(
        header => [
            From    => 'username@gmail.com',
            To      => 'to@mail.com',
            Subject => 'Subject title',
        ],
        body => 'Content.',
    );
    
    eval {
        $sender->send($message, {
            from => 'username@gmail.com',
            to   => [ 'to@mail.com' ],
        } );
    };
    die "Error sending email: $@" if $@;

=head1 DESCRIPTION

L<Email::Sender> replaces the old and sometimes problematic L<Email::Send> library, while this module replaces the L<Email::Send::SMTP::TLS>.

It's still alpha. use it at your own risk!

=head1 ATTRIBUTES

The following attributes may be passed to the constructor:

=over

=item host - the name of the host to connect to; defaults to localhost

=item port - port to connect to; defaults to 587

=item username - the username to use for auth; required

=item password - the password to use for auth; required

=item helo - what to say when saying HELO; no default

=item allow_partial_success - if true, will send data even if some recipients were rejected

=back

=head1 PARTIAL SUCCESS

If C<allow_partial_success> was set when creating the transport, the transport
may return L<Email::Sender::Success::Partial> objects.  Consult that module's
documentation.

=head1 AUTHOR

Fayland Lam, C<< <fayland at gmail.com> >>

=head1 ACKNOWLEDGEMENTS

Ricardo SIGNES - L<Email::Sender>

=head1 COPYRIGHT & LICENSE

Copyright 2008 Fayland Lam, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut
