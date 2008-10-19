package MooseX::Types::IO::All;

use warnings;
use strict;

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:FAYLAND';

use IO::All;

use MooseX::Types::Moose qw/Str ScalarRef FileHandle ArrayRef/;
use namespace::clean;
use MooseX::Types -declare => [qw( IO_All )];

class_type 'IO::All';
subtype IO_All, as 'IO::All';

coerce 'IO::All',
    from Str,
        via {
            io $_;
        },
    from ScalarRef,
        via {
            my $str = $$_;
            my $ios = io('$');
            $ios->print($str);
            return $ios;
        };

1;
__END__

=head1 NAME

MooseX::Types::IO::All - The great new MooseX::Types::IO::All!

=head1 SYNOPSIS

Quick summary of what the module does.

Perhaps a little code snippet.

    use MooseX::Types::IO;

    my $foo = MooseX::Types::IO->new();
    ...

=head1 EXPORT

A list of functions that can be exported.  You can delete this section
if you don't export anything, such as for a purely object-oriented module.

=head1 FUNCTIONS

=head2 function1

=cut

sub function1 {
}

=head2 function2

=cut

sub function2 {
}

=head1 AUTHOR

Fayland Lam, C<< <fayland at gmail.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-moosex-types-io at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=MooseX-Types-IO>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc MooseX::Types::IO


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=MooseX-Types-IO>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/MooseX-Types-IO>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/MooseX-Types-IO>

=item * Search CPAN

L<http://search.cpan.org/dist/MooseX-Types-IO>

=back


=head1 ACKNOWLEDGEMENTS


=head1 COPYRIGHT & LICENSE

Copyright 2008 Fayland Lam, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.


=cut

1; # End of MooseX::Types::IO
