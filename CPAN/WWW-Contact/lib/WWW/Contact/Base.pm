package WWW::Contact::Base;

use vars qw/$VERSION $AUTHORITY/;
use Moose::Role;
use Moose::Util::TypeConstraints;
use WWW::Mechanize;
use Data::Dumper;

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

has 'errstr' => ( is => 'rw', isa => 'Maybe[Str]' );

sub debug {
    my $self = shift;
    
    return unless $self->verbose;
    $self->verbose->(@_);
}

sub debug_to_file {
    my ($self, $file) = @_;
    
    open(my $fh, '>', $file);
    print $fh Dumper(\$self->ua);
    close($fh);
}

sub get_contacts_from_outlook_csv {
    my ($self, $csv) = @_;
    
    my @contacts;
    
    # Name,E-mail Address,Notes,
    my @lines = split(/\n/, $csv);
    shift @lines; # skip the first line
    foreach my $line (@lines) {
        my @cols = split(',', $line);
        next if ( $cols[1] !~ /\@/ ); # skip unknow lines
        push @contacts, {
            name  => $cols[0],
            email => $cols[1]
        };
    }
    
    return wantarray ? @contacts : \@contacts;
}

sub get {
    my $self = shift;
    
    my $resp = $self->ua->get(@_);
    unless ( $resp->is_success ) {
        $self->errstr( $resp->as_string() );
        return;
    }
    return 1;
}

sub submit_form {
    my $self = shift;
    
    my $resp = $self->ua->submit_form(@_);
    unless ( $resp->is_success ) {
        $self->errstr( $resp->as_string() );
        return;
    }
    return 1;
}

no Moose::Role;
no Moose::Util::TypeConstraints;

1;
__END__
