package Acme::PlayCode::Plugin::ExchangeCondition;

use Moose::Role;

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:FAYLAND';

around 'do_with_token' => sub {
    my $orig = shift;
    my $self = shift;
    my ( $token_flag ) = @_;
    
    my @tokens = $self->tokens;
    my $token  = $tokens[$token_flag];
    
    my $orginal_flag = $token_flag;
    if ( $token->isa('PPI::Token::Operator') ) {
        my $op = $token->content;
        # only 'ne' 'eq' '==' '!=' are exchange-able
        if ( $op eq 'ne' or $op eq 'eq' or $op eq '==' or $op eq '!=' ) {
            # get next tokens
            my (@next_tokens, @next_full_tokens);
            while ( $token_flag++ ) {
                if ($tokens[$token_flag]->isa('PPI::Token::Whitespace') ) {
                    push @next_full_tokens, $tokens[$token_flag];
                    next;
                }
                last if ( $tokens[$token_flag]->isa('PPI::Token::Structure') );
                if ( $tokens[$token_flag]->isa('PPI::Token::Operator') ) {
                    my $op2 = $tokens[$token_flag]->content;
                    if ( $op2 eq 'or' or $op2 eq 'and' or $op2 eq '||' or $op2 eq '&&') {
                        last;
                    }
                }
                last unless ( $tokens[$token_flag] );
                push @next_tokens, $tokens[$token_flag];
                push @next_full_tokens, $tokens[$token_flag];
            }
            $token_flag = $orginal_flag; # roll back
            # get previous tokens
            my (@previous_tokens, @previous_full_tokens);
            while ($token_flag--) {
                if ($tokens[$token_flag]->isa('PPI::Token::Whitespace') ) {
                    push @previous_full_tokens, $tokens[$token_flag];
                    next;
                }
                last if ($tokens[$token_flag]->isa('PPI::Token::Structure'));
                if ( $tokens[$token_flag]->isa('PPI::Token::Operator') ) {
                    my $op2 = $tokens[$token_flag]->content;
                    if ( $op2 eq 'or' or $op2 eq 'and' or $op2 eq '||' or $op2 eq '&&') {
                        last;
                    }
                }
                last unless ( $tokens[$token_flag] );
                push @previous_tokens, $tokens[$token_flag];
                push @previous_full_tokens, $tokens[$token_flag];
            }
            $token_flag = $orginal_flag; # roll back
            
            # the most simple situation ( $a eq 'a' )
            use Data::Dumper;
            if (scalar @next_tokens == 1 and scalar @previous_tokens == 1) {
                # exchange-able flag
                my $exchange_able = 0;
                # single and literal are exchange-able
                if ( $next_tokens[0]->isa('PPI::Token::Quote::Single')
                  or $next_tokens[0]->isa('PPI::Token::Quote::Literal') ) {
                    $exchange_able = 1;
                }
                # double without interpolations is exchange-able
                if ( $next_tokens[0]->isa('PPI::Token::Quote::Double') and
                    not $next_tokens[0]->interpolations ) {
                    $exchange_able = 1;
                }
                if ( $exchange_able ) {
                    # remove previous full tokens
                    my $previous_num = scalar @previous_full_tokens;
                    my $next_num     = scalar @next_full_tokens;
                    my @output = @{ $self->output };
                    @output = splice( @output, 0, scalar @output - $previous_num );
                    # exchange starts
                    foreach my $i ( $orginal_flag + 1 .. $orginal_flag + $next_num ) {
                        push @output, $orig->($self, $i);
                    }
                    # in case @next_full_tokens is closed with "a" instead of space
                    unless ($next_full_tokens[-1]->isa('PPI::Token::Whitespace')) {
                        push @output, ' ';
                    }
                    # space should be around $op
                    push @output, $op;
                    # in case @previous_full_tokens is started with $a instead of space
                    unless ($previous_full_tokens[0]->isa('PPI::Token::Whitespace')) {
                        push @output, ' ';
                    }
                    map { push @output, $_->content } @previous_full_tokens;
                    # move 'token flag' i forward
                    $token_flag += scalar @next_full_tokens + 1;
                    $self->token_flag( $token_flag );
                    $self->output( \@output );
                    return;
                }
            }
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
