package WWW::Zorpia::Journal;

use warnings;
use strict;
use vars qw/$VERSION %Category/;
use File::Spec;
use WWW::Mechanize;

$VERSION = '0.01';

%Category = (
    'Personal' => 10002,
    'Beauty & Fashion' => 10003,
    'Books' => 10004,
    'Celebrities & Models' => 10005,
    'Computer & Internet'  => 10006,
    'Food & Drinks' => 10007,
    'Games' => 10008,
    'Gossips & Jokes' => 10009,
    'Hobbies & Interests' => 10010,
    'Movies & Videos' => 10012,
    'Music' => 10013,
    'News & Sports' => 10014,
    'Photography & Art' => 10015,
    'Religion & Ethics' => 10016,
    'Romance & Relationships' => 10011,
    'Science' => 10017,
    'Travel'  => 10018,
    'TV' => 10019,
    'Zorpia-related' => 10021,
    'Miscellaneous' => 10020
);

sub new {
    my $class = shift;

    my $self = { };
    $self->{ua} = WWW::Mechanize->new(
        agent => 'Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1)',
        cookie_jar => {},
        stack_depth => 1,
    );
	return bless $self => $class;
}

sub login {
    my ($self, $username, $password) = @_;
    
    $self->{_username} = $username;
    $self->{ua}->get('http://www.zorpia.com/login');
    return 0 unless ($self->{ua}->success);
    
    $self->{ua}->submit_form(
        form_name => 'Login',
        fields    => {
            username => $username,
            password => $password,
            'goto'   => '/journal/new_journal',
        },
    );
    return 0 unless ($self->{ua}->success);
    
    my $login = ($self->{ua}->{base}->path =~ /login/) ? 0 : 1;
    $self->{_login_status} = $login;
    return $login;
}

sub journal {
    my ($self, $journal) = @_;
    
    return 0 unless ($self->{_login_status});
    
    # validate
    $journal->{title} ||= 'Untitled';
    $journal->{text}  ||= 'Zorpia Rocks';
    my $category_id = ($journal->{category_id}) ? $journal->{category_id}
                    : ($journal->{category} and $Category{ $journal->{category} }) ? $Category{ $journal->{category} }
                    : 10002;
    my $private = (exists $journal->{private}) ? $journal->{private}
                : (exists $journal->{public})  ? $journal->{public}
                : ($journal->{option} eq 'Private') ? 1
                : 0;
    
    unless ($self->{ua}->{base}->path =~ /new_journal/) {
        $self->{ua}->get('http://www.zorpia.com/journal/new_journal');
        return 0 unless ($self->{ua}->success);
    }
    $self->{ua}->submit_form(
        form_name => 'new_journal',
        fields    => {
            title => $journal->{title},
            category_id => $category_id,
            text => $journal->{text},
            private => $private,
            tags    => $journal->{tags} || '',
        },
    );
    return 0 unless ($self->{ua}->success);
    
    my $status = ($self->{ua}->{base}->path =~ /new_journal/) ? 0 : 1;
    return $status;
}

1;
__END__

=head1 NAME

WWW::Zorpia::Journal - Post a journal to www.zorpia.com

=head1 SYNOPSIS

    use WWW::Zorpia::Journal;

    my $zorpia = WWW::Zorpia::Journal->new();
    $zorpia->login('username', 'password');
    
    # post a journal
    $zorpia->journal( {
        title => 'Hello Zorpia', # required
        text  => 'Yup, this is fayland', # required
        category => 'Personal', # optional
        private => 1, # optional
        tags    => 'Zorpia Rocks', # optional
    } );

=head1 PARAMS FOR ->journal

=over 4

=item title

REQUIRED. journal title

=item text

REQUIRED. journal content

=item category

OPTIONAL. one of 'Personal', 'Beauty & Fashion', 'Books', 'Celebrities & Models', 'Computer & Internet', 'Food & Drinks', 'Games', 'Gossips & Jokes', 'Hobbies & Interests', 'Movies & Videos', 'Music', 'News & Sports', 'Photography & Art', 'Religion & Ethics', 'Romance & Relationships', 'Science', 'Travel', 'TV', 'Zorpia-related', 'Miscellaneous'. default is 'Personal'.

=item private

OPTIONAL. 0|1 0 means a public journal. everyone can read it. or else, just for yourself.

=item public

OPTIONAL. 0|1

=item tags

OPTIONAL. tag the journal.

=back

=head1 SHORTCOMING

If post journal fails, no error is reported. I will improve in next version. Or patches are welcome.

=head1 AUTHOR

Fayland Lam, C<< <fayland at gmail.com> >>

=head1 ACKNOWLEDGEMENTS

Zorpia L<http://www.zorpia.com> Company Ltd.

=head1 COPYRIGHT & LICENSE

Copyright 2007 Fayland Lam and Zorpia Company Ltd., all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1; # End of WWW::Zorpia::Journal
