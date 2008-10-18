#!/usr/bin/perl

use strict;
use warnings;
use Data::Dumper;
use PPI;

my $string = do { local $/; <DATA> };
my $doc = PPI::Document->new(\$string);

# get all token to print all out
my @tokens = @{ $doc->find('PPI::Token') };

my @tos; # print out array
my $i = 0; # token flag
while ($i <= $#tokens ) {
    my $token = $tokens[$i];
    #print Dumper(\$token);
    
    my $pushed = 0;
    my $orginal_i = $i;
    if ( $token->isa('PPI::Token::Operator') ) {
        my $op = $token->content;
        # only 'ne' 'eq' '==' '!=' are exchange-able
        if ( $op eq 'ne' or $op eq 'eq' or $op eq '==' or $op eq '!=' ) {
            # get next tokens
            my (@next_tokens, @next_full_tokens);
            while ( $i++ ) {
                if ($tokens[$i]->isa('PPI::Token::Whitespace') ) {
                    push @next_full_tokens, $tokens[$i];
                    next;
                }
                last if ( $tokens[$i]->isa('PPI::Token::Structure') );
                if ( $tokens[$i]->isa('PPI::Token::Operator') ) {
                    my $op2 = $tokens[$i]->content;
                    if ( $op2 eq 'or' or $op2 eq 'and' or $op2 eq '||' or $op2 eq '&&') {
                        last;
                    }
                }
                last unless ( $tokens[$i] );
                push @next_tokens, $tokens[$i];
                push @next_full_tokens, $tokens[$i];
            }
            $i = $orginal_i; # roll back
            # get previous tokens
            my (@previous_tokens, @previous_full_tokens);
            while ($i--) {
                if ($tokens[$i]->isa('PPI::Token::Whitespace') ) {
                    push @previous_full_tokens, $tokens[$i];
                    next;
                }
                last if ($tokens[$i]->isa('PPI::Token::Structure'));
                if ( $tokens[$i]->isa('PPI::Token::Operator') ) {
                    my $op2 = $tokens[$i]->content;
                    if ( $op2 eq 'or' or $op2 eq 'and' or $op2 eq '||' or $op2 eq '&&') {
                        last;
                    }
                }
                last unless ( $tokens[$i] );
                push @previous_tokens, $tokens[$i];
                push @previous_full_tokens, $tokens[$i];
            }
            $i = $orginal_i; # roll back
            
            # the most simple situation ( $a eq 'a' )
            if (scalar @next_tokens == 1 and scalar @previous_tokens == 1) {
                # exchange-able flag
                my $exchange_able = 0;
                # single and literal are exchange-able
                if ( $next_tokens[0]->isa('PPI::Token::Quote::Single') or $next_tokens[0]->isa('PPI::Token::Quote::Literal') ) {
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
                    @tos = splice( @tos, 0, scalar @tos - $previous_num );
                    # exchange starts
                    map { push @tos, $_->content } @next_full_tokens;
                    # in case @next_full_tokens is closed with "a" instead of space
                    push @tos, ' ' unless ($next_full_tokens[-1]->isa('PPI::Token::Whitespace'));
                    # space should be around $op
                    push @tos, $op;
                    # in case @previous_full_tokens is started with $a instead of space
                    push @tos, ' ' unless ($previous_full_tokens[0]->isa('PPI::Token::Whitespace'));
                    map { push @tos, $_->content } @previous_full_tokens;
                    # move 'token flag' i forward
                    $i += scalar @next_full_tokens;
                    $pushed = 1;
                }
            }
        }
    }

    $i++;
    push @tos, $token->content unless ( $pushed );
}

print join('', @tos);

__DATA__
my $a = "a";
my $b = "'b'";
my $c = 'c';
my $d = qq~d~;
if ( $a eq "a" ) {
    print "1";
} elsif ( $b eq 'b') {
    print "2";
} elsif ( $c ne qq~c~) {
    print "3"; 
} elsif ( $c eq q~d~) {
    print '4';
} else {
    print '5';
}
if ( $a eq $b ) {
    print '6';
}
if ( $c eq '$d' ) {
    print 7;
}
if ( $a =~ /$b/ ) {
    print 8;
}
if ( $a == '$b' or $c == '$d' ) {
    print 9;
}