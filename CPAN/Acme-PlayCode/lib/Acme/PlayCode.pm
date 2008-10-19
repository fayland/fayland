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

has 'tokens' => (
    is  => 'rw',
    isa => 'ArrayRef',
    auto_deref => 1,
    default    => sub { [] },
);
has 'token_flag' => ( is => 'rw', isa => 'Num', default => 0 );

has 'output' => (
    is => 'rw',
    isa => 'ArrayRef',
    default => sub { [] }
);

sub run {
    my ( $self ) = @_;
    
    # clear to multi-run
    $self->output( [] );
    $self->token_flag( 0 );
    
    my $doc    = PPI::Document->new( $self->io );
    $self->tokens( $doc->find('PPI::Token') );
    
    $self->do_with_tokens();
    
    my @output = @{ $self->output };
    return join('', @output);
}

sub do_with_tokens {
    my ( $self ) = @_;
    
    my @tokens = $self->tokens;
    while ( $self->token_flag < scalar @tokens) {
        my $orginal_flag = $self->token_flag;
        my $content = $self->do_with_token( $self->token_flag );
        push @{ $self->output }, $content if ( defined $content );
        # if we don't move token_flag, ++
        if ( $self->token_flag == $orginal_flag ) {
            $self->token_flag( $self->token_flag + 1 );
        }
    }
}

sub do_with_token {
    my ( $self, $token_flag ) = @_;

    my @tokens = $self->tokens;
    return $tokens[$token_flag]->content;
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
