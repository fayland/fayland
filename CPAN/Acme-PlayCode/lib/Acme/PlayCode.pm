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

Acme::PlayCode - Play code to win

=head1 SYNOPSIS

    use Acme::PlayCode;

    my $app = Acme::PlayCode->new( io => $filename );
    # or
    my $app = Acme::PlayCode->new( io => \$code );
    
    $app->load_plugin('DoubleToSingle');
    $app->load_plugin('ExchangeCondition');
    
    my $code_played = $app->run;

=head1 ALPHA WARNING

L<Acme::PlayCode> is still in its infancy. No fundamental changes are expected, but
nevertheless backwards compatibility is not yet guaranteed.

=head1 DESCRIPTION

It aims to change the code to be better (to be worse if you want).

More description and API detais will come later.

=head1 SEE ALSO

L<Moose>, L<PPI>, L<MooseX::Object::Pluggable>

=head1 AUTHOR

Fayland Lam, C<< <fayland at gmail.com> >>

=head1 ACKNOWLEDGEMENTS

The L<Moose> Team.

=head1 COPYRIGHT & LICENSE

Copyright 2008 Fayland Lam, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut
