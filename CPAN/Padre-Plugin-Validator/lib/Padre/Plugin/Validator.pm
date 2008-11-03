package Padre::Plugin::Validator;

use warnings;
use strict;

our $VERSION = '0.02';

use WebService::Validator::HTML::W3C;
use WebService::Validator::CSS::W3C;
use Wx ':everything';

my @menu = (
    ['Validate HTML', \&validate_html ],
    ['Validate CSS',  \&validate_css ],
);

sub menu {
    my ($self) = @_;
    return @menu;
}

sub validate_html {
	my ( $self ) = @_;
	
	my $doc  = $self->selected_document;
	my $code = $doc->text_get;
	
	unless ( $code and length($code) ) {
		Wx::MessageBox( 'No Code', 'Error', Wx::wxOK | Wx::wxCENTRE, $self );
	}
	
	my $v = WebService::Validator::HTML::W3C->new(
		detailed => 1
	);

	if ( $v->validate_markup($code) ) {
        if ( $v->is_valid ) {
			_output( $self, "HTML is valid\n" );
        } else {
			my $error_text = "HTML is not valid\n";
            foreach my $error ( @{$v->errors} ) {
                $error_text .= sprintf("%s at line %d\n", $error->msg, $error->line);
            }
            _output( $self, $error_text );
        }
    } else {
        my $error_text = sprintf("Failed to validate the code: %s\n", $v->validator_error);
        _output( $self, $error_text );
    }
}

sub validate_css {
	my ( $self ) = @_;
	
	my $doc  = $self->selected_document;
	my $code = $doc->text_get;
	
	unless ( $code and length($code) ) {
		Wx::MessageBox( 'No Code', 'Error', Wx::wxOK | Wx::wxCENTRE, $self );
	}
	
	my $val = WebService::Validator::CSS::W3C->new();
	my $ok  = $val->validate(string => $code);

	if ($ok) {
		if ( $val->is_valid ) {
			_output( $self, "CSS is valid\n" );
		} else {
			my $error_text = "CSS is not valid\n";
			$error_text .= "Errors:\n";
			my @errors = $val->errors;
			foreach my $err (@errors) {

#		{
#            'skippedstring' => '
#                                ;}
#                            ',
#            'context' => ' width ',
#            'errortype' => 'parse-error',
#            'message' => '
#        
#                                Parse error - Unrecognized 
#                            ',
#            'errorsubtype' => '
#                                skippedString
#                            ',
#            'line' => '20'
#          };

				my $message = $err->{message};
				$message =~ s/(^\s+|\s+$)//isg;
				$error_text .= " * $message ($err->{context}) at line $err->{line}\n";
			}
			_output( $self, $error_text );
		}
	} else {
		my $error_text = sprintf("Failed to validate the code\n");
        _output( $self, $error_text );
	}
}

sub _output {
	my ( $self, $text ) = @_;
	
	$self->show_output;
	$self->{output}->clear;
	$self->{output}->AppendText($text);
}

1;
__END__

=head1 NAME

Padre::Plugin::Validator - validate HTML/CSS in L<Padre>

=head1 SYNOPSIS

    $>padre
    Plugins -> Validator -> 
                            Validate HTML
                            Validate CSS

=head1 DESCRIPTION

validate HTML/CSS with L<WebService::Validator::HTML::W3C> / L<WebService::Validator::CSS::W3C>

It's within L<Padre>. error will be shown in output window.

=head1 SEE ALSO

L<WebService::Validator::HTML::W3C>, L<WebService::Validator::CSS::W3C>

=head1 AUTHOR

Fayland Lam, C<< <fayland at gmail.com> >>

=head1 COPYRIGHT & LICENSE

Copyright 2008 Fayland Lam, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut
