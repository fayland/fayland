package Acme::PlayCode::Plugin::DoubleToSingle;

use Moose::Role;

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:FAYLAND';

around 'do_with_token' => sub {
    my $orig = shift;
    my $self = shift;
    my ( $token ) = @_;
    
    if ( $token->isa('PPI::Token::Quote::Double') ) {
        unless ( $token->interpolations ) {
            my $str = $token->string;
            if ( $str !~ /\'/) {
                return "'$str'";
            } else {
                if ( $str !~ /\~/ ) {
                    return 'q~' . $str . '~';
                } else {
                    return $token->content;
                }
            }
        }
    } elsif ( $token->isa('PPI::Token::Quote::Interpolate') ) {
        # PPI::Token::Quote::Interpolate no ->interpolations
        my $str = $token->string;
        if ( $str =~ /^\w+$/ ) {
            return "'$str'";
        }
    }
    
    $orig->($self, @_);
};

no Moose::Role;

1;
__END__

=head1 NAME

Acme::PlayCode::Plugin::DoubleToSingle - The great new Acme::PlayCode::Plugin::DoubleToSingle!

=head1 SYNOPSIS

    use Acme::PlayCode;

    my $app = Acme::PlayCode->new();
    
    $app->load_plugin('DoubleToSingle');
    
    $app->run;

=head1 AUTHOR

Fayland Lam, C<< <fayland at gmail.com> >>

=head1 COPYRIGHT & LICENSE

Copyright 2008 Fayland Lam, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut
