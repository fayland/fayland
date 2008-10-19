package Acme::PlayCode;

use Moose;
use PPI;

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:FAYLAND';

with 'MooseX::Object::Pluggable';

has 'io' => (
    is  => 'rw',
    isa => 'Str|ScalarRef',
);

has 'ppi' => (
    is  => 'ro',
    isa => 'PPI::Document',
    lazy => 1,
    default => sub {
        PPI::Document->new( (shift)->io );
    }
);

has 'output' => (
    is => 'rw',
    isa => 'ArrayRef',
    default => sub { [] }
);

sub run {
    my ( $self ) = @_;
    
    foreach my $token ( @{ $self->ppi->find('PPI::Token') } ) {
        push @{ $self->output }, $self->do_with_token($token);
    }
    
    my @output = @{ $self->output };
    return join('', @output);
}

sub do_with_token {
    my ( $self, $token ) = @_;
    
    $token->content;
}

no Moose;
1;
__END__

=head1 NAME

Acme::PlayCode - The great new Acme::PlayCode!

=head1 SYNOPSIS

    use Acme::PlayCode;

    my $app = Acme::PlayCode->new();
    
    $app->load_plugin('DoubleToSingle');
    
    $app->run;

=head1 AUTHOR

Fayland Lam, C<< <fayland at gmail.com> >>

=head1 ACKNOWLEDGEMENTS

The L<Moose> Team.

=head1 COPYRIGHT & LICENSE

Copyright 2008 Fayland Lam, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut
