package WWW::Contact::Base;

use warnings;
use strict;
use vars qw/$VERSION $AUTHORITY/;
use Moose::Role;
use Moose::Util::TypeConstraints;
use WWW::Mechanize;

my $sub_verbose = sub {
    my $msg = shift;
    $msg =~ s/\s+$//;
    print STDERR "$msg\n";
};
subtype 'Verbose'
    => as 'CodeRef'
    => where { 1; };
coerce 'Verbose'
    => from 'Int'
    => via {
        if ($_) {
            return $sub_verbose;
        } else {
            return sub { 0 };
        }
    };

has 'verbose' => ( is => 'rw', isa => 'Verbose', coerce => 1, default => 0 );
has 'ua' => (
    is => 'rw',
    isa => 'WWW::Mechanize',
    lazy => 1,
    default => sub {
        WWW::Mechanize->new(
            agent       => 'Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1)',
            cookie_jar  => {},
            stack_depth => 1,
            timeout     => 60,
        );
    }
);

has 'errstr' => ( is => 'rw', isa => 'Str' );

sub debug {
    my $self = shift;
    
    return unless $self->verbose;
    $self->verbose->(@_);
}

no Moose::Role;
no Moose::Util::TypeConstraints;

1;
__END__
