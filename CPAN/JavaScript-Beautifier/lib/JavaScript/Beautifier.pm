package JavaScript::Beautifier;

use warnings;
use strict;

our $VERSION = '0.01';
our $AUTHORITY = 'cpan:FAYLAND';

use Mouse;

has 'indent_size'  => ( is => 'ro', isa => 'Int', default => 4 );
has 'indent_character' => ( is => 'ro', isa => 'Str', default => ' ' );
has 'indent_level' => ( is => 'ro', isa => 'Int', default => 0 );

sub js_beautify {
	my ( $self, $js_source_code ) = @_;
	
	my ( @input, @output, $token_text, $last_type, $last_text, $last_word, $current_mode,
	     @modes, $indent_string, @whitespace, @wordchar, @punct, $parser_pos,
	     @line_starter, $in_case, $prefix, $token_type, $do_block_just_closed,
	     $var_line, $var_line_tainted, $if_line_flag );

	sub trim_output {
		while ( scalar @output && ( $output[ scalar @output - 1 ] eq '' || $output[ scalar @output - 1 ] eq $indent_string ) ) {
			pop @output;
		}
	}
	sub print_newline {
		my ( $ingore_repeated ) = @_;
		$ignore_repeated = 1 unless defined $ignore_repeated;
		$if_line_flag = 0;
		trim_output();
		
		if ( not scalar @output ) {
			return; # no newline on start of file
		}
		
		if ( $output[ scalar @output - 1 ] ne "\n" || ! $ingore_repeated ) {
			push @output, "\n";
		}
		foreach my $i ( 0 .. $self->indent_level ) {
			push @output, $indent_string;
		}
	}

	sub print_space {
		my $last_output = scalar @output ? $output[ scalar @output - 1 ] : ' ';
		if ( $last_output ne ' ' && $last_output ne "\n" && $last_output ne $indent_string ) { # prevent occassional duplicate space
			push @output, ' ';
		}
	}
	
	sub print_token {
		push @output, $token_text;
	}
	sub indent {
		$self->indent_level++;
	}
	sub unindent {
		if ( $self->indent_level ) {
			$self->indent_level--;
		}
	}
	sub remove_indent {
		if ( scalar @output && $output[ scalar @output - 1 ] eq $indent_string ) {
			pop @output;
		}
	}
	sub set_mode {
		my $mode = shift;
		push @modes, $current_mode;
		$current_mode = $mode;
	}
	sub restore_mode {
		$do_block_just_closed = ( $current_mode eq 'DO_BLOCK' );
		$current_mode = pop @modes;
	}
	sub get_next_token {
		my $n_newlines = 0;
		my $c = '';
		while ( grep { $_ eq $c } @whitespace ) ( {
			if ( $parser_pos >= scalar @input ) {
				return ['', 'TK_EOF'];
			}
			$c = $input[$parser_pos];
			if ( $c eq "\n" ) {
				$n_newlines += 1;
			}
		}
		if ( $n_newlines > 1 ) {
			foreach my $i ( 0 .. 2 ) {
				print_newline( $i == 0 );
			}
		}
		my $wanted_newline = ($n_newlines == 1 );
		if ( grep { $c eq $_ } @wordchar ) {
			if ( $parser_pos < scalar @input ) {
				while ( grep { $input[$parser_pos] eq $_ } @wordchar ) {
					$c .= $input[$parser_pos];
					$parser_pos++;
					if ( $parser_pos == scalar @input ) {
						last;
					}
				}
			}
			
			# small and surprisingly unugly hack for 1E-10 representation
			if ( $parser_pos != scalar @input && $c =~ /^[0-9]+[Ee]$/ && $input[$parser_pos] eq '-' ) {
				$parser_pos++;
				my $t = get_next_token($parser_pos);
				$c .= '-' . $t->[0];
				return [$c, 'TK_WORD'];
			}
			if ( $c eq 'in' ) { # hack for 'in' operator
				return [$c, 'TK_OPERATOR'];
			}
			if ( $wanted_newline && $last_type ne 'TK_OPERATOR' && not $if_line_flag ) {
				print_newline();
			}
			return [$c, 'TK_WORD'];
		}
		if ( $c eq '(' || $c eq '[' ) {
			return [$c, 'TK_START_EXPR'];
		}
		if ( $c eq ')' || $c eq ']' ) {
			return [$c, 'TK_END_EXPR'];
		}
		if ( $c eq '{' ) {
			return [$c, 'TK_START_BLOCK'];
		}
		if ( $c eq '}' ) {
			return [$c, 'TK_END_BLOCK'];
		}
		if ( $c eq ';' ) {
			return [$c, 'TK_SEMICOLON'];
		}
		if ( $c eq '/' ) {
			my $comment;
			# peek for comment /* ... */
			if ( $input[$parser_pos] eq '*' ) {
				$parser_pos++;
				if ( $parser_pos < scalar @input ) {
					while (not ( $input[$parser_pos] eq '*' && $input[$parser_pos+1] && $input[$parser_pos+1] eq '/') && $parser_pos < scalar @input ) {
						$comment .= $input[$parser_pos];
						$parser_pos++;
						if ( $parser_pos >= scalar @input ) {
							last;
						}
					}
				}
				$parser_pos += 2;
				return ['/*' . $comment . '*/', 'TK_BLOCK_COMMENT'];
			}
			# peek for comment // ...
			if ( $input[$parser_pos] eq '/' ) {
				$comment = $c;
				while ( $input[$parser_pos] ne "\x0d" && $input[$parser_pos] ne "\x0a" ) {
					$comment .= $input[$parser_pos];
					$paser_pos++;
					if ( $parser_pos >= scalar @input ) {
						last;
					}
				}
				$parser_pos++;
				if ($wanted_newline) {
					print_newline();
				}
				return [$comment, 'TK_COMMENT'];
			}
		}
		if ( $c eq "'" || # string
		     $c eq '"' || # string
		    ($c eq '/' &&
		    (( $last_type eq 'TK_WORD' && $last_text eq 'return') ||
		     ( $last_type eq 'TK_START_EXPR' || $last_type eq 'TK_END_BLOCK' || $last_type eq 'TK_OPERATOR' || $last_type eq 'TK_EOF' || $last_type eq 'TK_SEMICOLON')))) { # regexp
		     my $sep = $c;
		     my $esc = 0;
		     my $resulting_string;
		     if ( $parser_pos < scalar @input ) {
		     	while ( $esc || $input[$parser_pos] ne $sep ) {
		     		$resulting_string .= $input[$parser_pos];
		     		if ( not $esc ) {
		     			$esc = ( $input[$parser_pos] eq '\\' );
		     		} else {
		     			$esc = 0;
		     		}
		     		$parser_pos++;
		     		last if ( $parser_pos >= scalar @input );
		     	}
		     }
		     $parser_pos++;
		     $resulting_string = $sep . $resulting_string . $sep;
		     if ( $sep eq '/' ) {
		     	# regexps may have modifiers /regexp/MOD , so fetch those, too
		     	while ( $parser_pos < scalar @input && grep { $input[$parser_pos] eq $_ } @wordchar ) {
		     		$resulting_string .= $input[$parser_pos];
		     		$parser_pos++;
		    	}
		    }
		    return [$resulting_string, 'TK_STRING'];
		}
		if ( grep { $c eq $_ } @punct ) {
		 	while ( $parser_pos < scalar @input && grep { $c . $input[$parser_pos] eq $_ } @punct ) {
		 		$c .= $input[$parser_pos];
		 		$parser_pos++;
		 		last if ( $parser_pos >= scalar @input );
		 	}
		 	return [$c, 'TK_OPERATOR'];
		}
		return [$c, 'TK_UNKNOWN'];
	}
	
	# -------------------------------------
	$indent_string = '';
	while ( $self->indent_size-- ) {
		$indent_string .= $self->indent_character;
	}
	@input = split('', $js_source_text);
	
	$last_word = ''; # last 'TK_WORD' passed
    $last_type = 'TK_START_EXPR'; # last token type
    $last_text = ''; # last token text
    @output = ();

	$do_block_just_closed = 0;
	$var_line = 0;
	$var_line_tainted = 0;
	
	@whitespace = split('', "\n\r\t");
	@wordchar   = split('', 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_$');
	@punct      = split(' ', '+ - * / % & ++ -- = += -= *= /= %= == === != !== > < >= <= >> << >>> >>>= >>= <<= && &= | || ! !! , : ? ^ ^= |= ::');
	
	# words which should always start on new line.
	@line_starter = split(',', 'continue,try,throw,return,var,if,switch,case,default,for,while,break,function');

    # states showing if we are currently in expression (i.e. "if" case) - 'EXPRESSION', or in usual block (like, procedure), 'BLOCK'.
    # some formatting depends on that.
    $current_mode = 'BLOCK';
    @modes = ( $current_mode );
    
    $indent_level ||= 0;
    $parser_pos = 0; # parser position
    $in_case = 0; # flag for parser that case/default has been processed, and next colon needs special attention
    while ( 1 ) {
    	my $t = get_next_token($parser_pos);
    	$token_text = $t->[0];
    	$token_type = $t->[1];
    	if ( $token_type eq 'TK_EOF' ) {
    		last;
    	}
    	
    	if ( $token_type eq 'TK_START_EXPR' ) {
    		$var_line = 0;
    		set_mode('EXPRESSION');
    		if ( $last_type eq 'TK_END_EXPR' || $last_type eq 'TK_START_EXPR' ) {
    			# do nothing on (( and )( and ][ and ]( ..
    		} elsif ( $last_type ne 'TK_WORD' && $last_type ne 'TK_OPERATOR' ) {
    			print_space();
    		} elsif ( grep { $last_word eq $_ } @line_starters && $last_word ne 'function' ) {
    			print_space();
    		}
    		print_token();
    		next;
    	} elsif ( $token_type eq 'TK_END_EXPR' ) {
    		print_token();
    		restore_mode();
    		next;
    	} elsif ( $token_type eq 'TK_START_BLOCK' ) {
    		if ( $last_word eq 'do' ) {
    			set_mode('DO_BLOCK');
    		} else {
    			set_mode('BLOCK');
    		}
    		if ( $last_type ne 'TK_OPERATOR' && $last_type ne 'TK_START_EXPR' ) {
    			if ( $last_type eq 'TK_START_BLOCK' ) {
    				print_newline();
    			} else {
    				print_space();
    			}
    		}
    		print_token();
    		indent();
    		next;
    	} elsif ( $token_type eq 'TK_END_BLOCK' ) {
    		if ( $last_type eq 'TK_START_BLOCK' ) {
    			# nothing
    			trim_output();
    			unindent();
    		} else {
    			unindent();
    			print_newline();
    		}
    		print_token();
    		restore_mode();
    		next;
    	} elsif ( $token_type eq 'TK_WORD' ) {
    		if ( $do_block_just_closed ) {
    			print_space();
    			print_token();
    			print_space();
    			next;
    		}
    		if ( $token_text eq 'case' || $token_text eq 'default' ) {
    			if ( $last_text eq ':' ) {
    				# switch cases following one another
                    remove_indent();
                } else {
					# case statement starts in the same line where switch
                    unindent();
                    print_newline();
                    indent();
                }
                print_token();
                in_case = 0;
                next;
            }
            $prefix = 'NONE';
            if ( $last_type eq 'TK_END_BLOCK' ) {
            	if ( not grep { lc($token_text) eq $_ } ('else', 'catch', 'finally') ) {
					$prefix = 'NEWLINE';
				} else {
					$prefix = 'SPACE';
					print_space();
				}
			} elsif ( $last_type eq 'TK_SEMICOLON' && ( $current_mode eq 'BLOCK' || $current_mode eq 'DO_BLOCK' ) ) {
				$prefix = 'NEWLINE';
			} elsif ( $last_type eq 'TK_SEMICOLON' && $current_mode eq 'EXPRESSION' ) {
				$prefix = 'SPACE';
			} elsif ( $last_type eq 'TK_STRING') {
				$prefix = 'NEWLINE';
			} elsif ( $last_type eq 'TK_WORD' ) {
				$prefix = 'SPACE';
			} elsif ( $last_type eq 'TK_START_BLOCK') {
				$prefix = 'NEWLINE';
			} elsif ( $last_type eq 'TK_END_EXPR' ) {
				print_space();
				$prefix = 'NEWLINE';
			}
            	
}
#            if (last_type !== 'TK_END_BLOCK' && in_array(token_text.toLowerCase(), ['else', 'catch', 'finally'])) {
#                print_newline();
#            } else if (in_array(token_text, line_starters) || prefix === 'NEWLINE') {
#                if (last_text === 'else') {
#                    // no need to force newline on else break
#                    print_space();
#                } else if ((last_type === 'TK_START_EXPR' || last_text === '=') && token_text === 'function') {
#                    // no need to force newline on 'function': (function
#                    // DONOTHING
#                } else if (last_type === 'TK_WORD' && (last_text === 'return' || last_text === 'throw')) {
#                    // no newline between 'return nnn'
#                    print_space();
#                } else if (last_type !== 'TK_END_EXPR') {
#                    if ((last_type !== 'TK_START_EXPR' || token_text !== 'var') && last_text !== ':') {
#                        // no need to force newline on 'var': for (var x = 0...)
#                        if (token_text === 'if' && last_type === 'TK_WORD' && last_word === 'else') {
#                            // no newline for } else if {
#                            print_space();
#                        } else {
#                            print_newline();
#                        }
#                    }
#                } else {
#                    if (in_array(token_text, line_starters) && last_text !== ')') {
#                        print_newline();
#                    }
#                }
#            } else if (prefix === 'SPACE') {
#                print_space();
#            }
#            print_token();
#            last_word = token_text;
# 
#            if (token_text === 'var') {
#                var_line = true;
#                var_line_tainted = false;
#            }
# 
#            if (token_text === 'if' || token_text === 'else') {
#                if_line_flag = true;
#            }
# 
#            break;
# 
#        case 'TK_SEMICOLON':
# 
#            print_token();
#            var_line = false;
#            break;
# 
#        case 'TK_STRING':
# 
#            if (last_type === 'TK_START_BLOCK' || last_type === 'TK_END_BLOCK' || last_type == 'TK_SEMICOLON') {
#                print_newline();
#            } else if (last_type === 'TK_WORD') {
#                print_space();
#            }
#            print_token();
#            break;
# 
#        case 'TK_OPERATOR':
# 
#            var start_delim = true;
#            var end_delim = true;
#            if (var_line && token_text !== ',') {
#                var_line_tainted = true;
#                if (token_text === ':') {
#                    var_line = false;
#                }
#            }
# 
#            if (token_text === ':' && in_case) {
#                print_token(); // colon really asks for separate treatment
#                print_newline();
#                break;
#            }
# 
#            if (token_text === '::') {
#                // no spaces around exotic namespacing syntax operator
#                print_token();
#                break;
#            }
# 
#            in_case = false;
# 
#            if (token_text === ',') {
#                if (var_line) {
#                    if (var_line_tainted) {
#                        print_token();
#                        print_newline();
#                        var_line_tainted = false;
#                    } else {
#                        print_token();
#                        print_space();
#                    }
#                } else if (last_type === 'TK_END_BLOCK') {
#                    print_token();
#                    print_newline();
#                } else {
#                    if (current_mode === 'BLOCK') {
#                        print_token();
#                        print_newline();
#                    } else {
#                        // EXPR od DO_BLOCK
#                        print_token();
#                        print_space();
#                    }
#                }
#                break;
#            } else if (token_text === '--' || token_text === '++') { // unary operators special case
#                if (last_text === ';') {
#                    // space for (;; ++i)
#                    start_delim = true;
#                    end_delim = false;
#                } else {
#                    start_delim = false;
#                    end_delim = false;
#                }
#            } else if (token_text === '!' && last_type === 'TK_START_EXPR') {
#                // special case handling: if (!a)
#                start_delim = false;
#                end_delim = false;
#            } else if (last_type === 'TK_OPERATOR') {
#                start_delim = false;
#                end_delim = false;
#            } else if (last_type === 'TK_END_EXPR') {
#                start_delim = true;
#                end_delim = true;
#            } else if (token_text === '.') {
#                // decimal digits or object.property
#                start_delim = false;
#                end_delim = false;
# 
#            } else if (token_text === ':') {
#                // zz: xx
#                // can't differentiate ternary op, so for now it's a ? b: c; without space before colon
#                if (last_text.match(/^\d+$/)) {
#                    // a little help for ternary a ? 1 : 0;
#                    start_delim = true;
#                } else {
#                    start_delim = false;
#                }
#            }
#            if (start_delim) {
#                print_space();
#            }
# 
#            print_token();
# 
#            if (end_delim) {
#                print_space();
#            }
#            break;
# 
#        case 'TK_BLOCK_COMMENT':
# 
#            print_newline();
#            print_token();
#            print_newline();
#            break;
# 
#        case 'TK_COMMENT':
# 
#            // print_newline();
#            print_space();
#            print_token();
#            print_newline();
#            break;
# 
#        case 'TK_UNKNOWN':
#            print_token();
#            break;
#        }
# 
#        last_type = token_type;
#        last_text = token_text;
#    }
# 
#    return output.join('');
# 
#}

1;
__END__

=head1 NAME

JavaScript::Beautifier - The great new JavaScript::Beautifier!

=head1 SYNOPSIS

    use JavaScript::Beautifier;

    my $foo = JavaScript::Beautifier->new();
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

Please report any bugs or feature requests to C<bug-javascript-beautifier at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=JavaScript-Beautifier>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc JavaScript::Beautifier


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=JavaScript-Beautifier>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/JavaScript-Beautifier>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/JavaScript-Beautifier>

=item * Search CPAN

L<http://search.cpan.org/dist/JavaScript-Beautifier/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 COPYRIGHT & LICENSE

Copyright 2008 Fayland Lam, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.


=cut

1; # End of JavaScript::Beautifier
