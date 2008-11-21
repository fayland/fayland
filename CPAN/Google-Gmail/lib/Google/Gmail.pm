package Google::Gmail;

use warnings;
use strict;

our $VERSION = '0.01';


1;
__END__

=head1 NAME

Google::Gmail - The great new Google::Gmail!

=head1 SYNOPSIS

    use Google::Gmail;

    my $ga = Google::Gmail->new("google@gmail.com", "mymailismypass");
    $ga->login();
    my @folder = $ga->getMessagesByFolder('inbox');
	
	foreach my $thread ( @folder ) {
		print $thread->id, $thread->len, $thread->subject, "\n";
		foreach my $msg ( @{ $thread->msgs } ) {
			print "  ", $msg->id, $msg->number, $msg->subject, "\n";
			print $msg->source, "\n";
		}
	}

=head1 DESCRIPTION

Gmail is L<https://mail.google.com/mail/>

=over 4

=item libgmail

libgmail ¡ª Python binding for Google's Gmail service

L<http://sourceforge.net/projects/libgmail/>

=cut

=head1 AUTHOR

Fayland Lam, C<< <fayland at gmail.com> >>

=head1 COPYRIGHT & LICENSE

Copyright 2008 Fayland Lam, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut
