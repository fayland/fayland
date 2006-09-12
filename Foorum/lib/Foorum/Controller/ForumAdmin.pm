package Foorum::Controller::ForumAdmin;

use strict;
use warnings;
use base 'Catalyst::Controller';
use File::Slurp;
use YAML::Syck;
use Foorum::Utils qw/is_color/;
use Data::Dumper;

sub begin : Private {
    my ($self, $c) = @_;
    
    $c->stash( {
        no_online_view => 1,
#        no_url_referer => 1,
    } );
}

sub home : LocalRegex('^(\d+)$') {
    my ($self, $c) = @_;
    
    my $forum_id = $c->req->snippets->[0];
    my $forum = $c->forward('/get/forum', [ $forum_id ]);
    &_check_policy( $self, $c, $forum );
    
    $c->stash->{template} = 'forumadmin/index.html';
}

sub basic : LocalRegex('^(\d+)/basic$') {
    my ($self, $c) = @_;
    
    my $forum_id = $c->req->snippets->[0];
    my $forum = $c->forward('/get/forum', [ $forum_id ]);
    
    $c->stash( {
        template => 'forumadmin/basic.html',
    } );
    
    my $role = $c->controller('Policy')->get_forum_moderators($c, $forum_id);
    unless ($c->req->param('submit')) {
        # get all moderators
        my $e_moderators = $role->{$forum_id}->{moderator};
        if ($e_moderators) {
            my @e_moderators = @{ $e_moderators };
            my @moderator_username;
            push @moderator_username, $_->username foreach (@e_moderators);
            $c->stash->{moderators} = join(',', @moderator_username);
        }
        $c->stash->{private} = ($forum->policy eq 'private')?1:0;
        return;
    }
        
    &_check_policy( $self, $c, $forum );
    
    # validate
    $c->form(
        name => [qw/NOT_BLANK/,             [qw/LENGTH 1 40/] ],
#        description  => [qw/NOT_BLANK/ ],
    );
    return if ($c->form->has_error);
    
    my $name  = $c->req->param('name');
    my $description = $c->req->param('description');
    my $moderators  = $c->req->param('moderators');
    my $private = $c->req->param('private');

    # get forum admin
    my $admin = $role->{$forum_id}->{admin};
    my $admin_username = $admin->username if ($admin);

    my @moderators = split(/\s*\,\s*/, $moderators);
    my @moderator_users;
    foreach (@moderators) {
        next if ($_ eq $admin_username); # avoid the same man
        last if (scalar @moderator_users > 2); # only allow 3 moderators at most
        my $moderator_user = $c->model('DBIC::User')->find( { username => $_ } );
        unless ($moderator_user) {
            $c->stash->{non_existence_user} = $_;
            return $c->set_invalid_form( moderators => 'ADMIN_NONEXISTENCE' );
        }
        push @moderator_users, $moderator_user;
    }
    
    # insert data into table.
    my $policy = ($private == 1)?'private':'public';
    $forum->update( {
        name => $name,
        description => $description,
#        type => 'classical',
        policy => $policy,
    } );

    # delete before create
    $c->model('DBIC::UserRole')->search( {
        role    => 'moderator',
        field   => $forum->forum_id,
    } )->delete;
    foreach (@moderator_users) {
        $c->model('DBIC::UserRole')->create( {
            user_id => $_->user_id,
            role    => 'moderator',
            field   => $forum->forum_id,
        } );
    }
    
    $c->res->redirect("/forum/$forum_id");
}

sub style : LocalRegex('^(\d+)/style$') {
    my ($self, $c) = @_;
    
    my $forum_id = $c->req->snippets->[0];
    my $forum = $c->forward('/get/forum', [ $forum_id ]);
    
    $c->stash->{template} = 'forumadmin/style.html';
    
    # style.yml and style.css
    my $yml = $c->path_to('style', 'custom', "forum$forum_id\.yml");

    unless ($c->req->param('submit')) {
        if (-e $yml) {
            my $style = LoadFile($yml);
            $c->stash->{style} = $style;
        }
        return;
    }
    
    # execute validation.
    $c->form(
        bg_color => [ ['REGEX', qr/^\#[0-9a-zA-Z]{6}$/ ] ],
        bg_fontcolor => [ ['REGEX', qr/^\#[0-9a-zA-Z]{6}$/ ] ],
        alink => [ ['REGEX', qr/^\#[0-9a-zA-Z]{6}$/ ] ],
        vlink => [ ['REGEX', qr/^\#[0-9a-zA-Z]{6}$/ ] ],
        hlink => [ ['REGEX', qr/^\#[0-9a-zA-Z]{6}$/ ] ],
        tablebordercolor => [ ['REGEX', qr/^\#[0-9a-zA-Z]{6}$/ ] ],
        titlecolor => [ ['REGEX', qr/^\#[0-9a-zA-Z]{6}$/ ] ],
        titlefont => [ ['REGEX', qr/^\#[0-9a-zA-Z]{6}$/ ] ],
        forumcolor1 => [ ['REGEX', qr/^\#[0-9a-zA-Z]{6}$/ ] ],
        forumfont1 => [ ['REGEX', qr/^\#[0-9a-zA-Z]{6}$/ ] ],
        forumcolor2 => [ ['REGEX', qr/^\#[0-9a-zA-Z]{6}$/ ] ],
        forumfont2 => [ ['REGEX', qr/^\#[0-9a-zA-Z]{6}$/ ] ],
        replycolor1 => [ ['REGEX', qr/^\#[0-9a-zA-Z]{6}$/ ] ],
        replyfont1 => [ ['REGEX', qr/^\#[0-9a-zA-Z]{6}$/ ] ],
        replycolor2 => [ ['REGEX', qr/^\#[0-9a-zA-Z]{6}$/ ] ],
        replyfont2 => [ ['REGEX', qr/^\#[0-9a-zA-Z]{6}$/ ] ],
        misccolor1 => [ ['REGEX', qr/^\#[0-9a-zA-Z]{6}$/ ] ],
        miscfont1 => [ ['REGEX', qr/^\#[0-9a-zA-Z]{6}$/ ] ],
        misccolor2 => [ ['REGEX', qr/^\#[0-9a-zA-Z]{6}$/ ] ],
        miscfont2 => [ ['REGEX', qr/^\#[0-9a-zA-Z]{6}$/ ] ],
        highlight => [ ['REGEX', qr/^\#[0-9a-zA-Z]{6}$/ ] ],
        semilight => [ ['REGEX', qr/^\#[0-9a-zA-Z]{6}$/ ] ],
        tablewidth => [ ['BETWEEN', 70, 100] ],
        bg_image  => [ 'HTTP_URL', ['REGEX', qr/^(gif|jpe?g|png)$/ ] ],
    );

    return if ($c->form->has_error);

    &_check_policy( $self, $c, $forum );
    
    # save the style.yml and style.css
    my $css = $c->path_to('root', 'css', 'custom', "forum$forum_id\.css");
    
    my $style = $c->req->params;
    
    my $css_content = $c->view('NoWrapperTT')->render($c, 'common/style.css', {
        additional_template_paths => [ $c->path_to('templates', $c->stash->{lang}) ],
        style => $style,
    } );
#    write_file($css, $css_content);
    if (open(FH, '>', $css)) {
        flock(FH, 2);
        print FH $css_content;
        close(FH);
    }
    
    my $yml_content = $c->view('NoWrapperTT')->render($c, 'common/style.yml', {
        additional_template_paths => [ $c->path_to('templates', $c->stash->{lang}) ],
        style => $style,
    } );
#    write_file($yml, $yml_content);
    if (open(FH, '>', $yml)) {
        flock(FH, 2);
        print FH $yml_content;
        close(FH);
    }
    
    $c->res->redirect("/forum/$forum_id");
}

sub del_style : LocalRegex('^(\d+)/del_style$') {
    my ($self, $c) = @_;
    
    my $forum_id = $c->req->snippets->[0];
    my $forum = $c->forward('/get/forum', [ $forum_id ]);
    
    &_check_policy( $self, $c, $forum );
    
    my $yml = $c->path_to('style', 'custom', "forum$forum_id\.yml");
    my $css = $c->path_to('root', 'css', 'custom', "forum$forum_id\.css");
    
    unlink $yml if (-e $yml);
    unlink $css if (-e $css);
    
    $c->res->redirect("/forum/$forum_id");
}

sub announcement : LocalRegex('^(\d+)/announcement$') {
    my ($self, $c) = @_;
    
    my $forum_id = $c->req->snippets->[0];
    my $forum = $c->forward('/get/forum', [ $forum_id ]);
    
    my $announce = $c->model('DBIC::Comment')->find( {
        object_id   => $forum_id,
        object_type => 'announcement',
    } );
    
    unless ($c->req->param('submit')) {
        $c->stash( {
            template => 'forumadmin/announcement.html',
            announce => $announce,
        } );
        return;
    }
    
    &_check_policy( $self, $c, $forum );
    
    my $text  = $c->req->param('announcement');
    my $title = $c->req->param('title');
    
    # if no text is typed, delete the record.
    # or else, save it.
    if (length($text) and length($title)) {
        if ($announce) {
            $announce->update( {
                text        => $text,
                update_on   => \"NOW()",
                author_id   => $c->user->user_id,
                title       => $title,
            } );
        } else {
            $c->model('DBIC::Comment')->create( {
                object_id   => $forum_id,
                object_type => 'announcement',
                forum_id    => $forum_id,
                text        => $text,
                post_on     => \"NOW()",
                author_id   => $c->user->user_id,
                title       => $title,
            } );
        }
    } else {
        $c->model('DBIC::Comment')->search( {
            object_id   => $forum_id,
            object_type => 'announcement',
        } )->delete;
    }
    
    $c->res->redirect("/forum/$forum_id");
}

sub block_user : LocalRegex('^(\d+)/block_user$') {
    my ($self, $c) = @_;
    
    my $forum_id = $c->req->snippets->[0];
    my $forum = $c->forward('/get/forum', [ $forum_id ]);
    
    $c->stash->{template} = 'forumadmin/block_user.html';
    unless ($c->req->param('submit')) {
        my @blocked_users = $c->model('DBIC::UserRole')->search( {
            role  => 'blocked',
            field => $forum_id,
        }, {
            prefetch => ['user'],
        } )->all;
        $c->stash->{blocked_users} = \@blocked_users;
        return;
    }
    
    # first of all, delete all records
    # TODO
    my $users = $c->req->param('users');
} 

sub _check_policy {
    my ( $self, $c, $forum ) = @_;
    
    unless ($c->forward('/policy/is_admin', [ $forum->forum_id ])) {
        $c->detach('/print_error', [ 'ERROR_PERMISSION_DENIED' ]);
    }
}

=pod

=head2 AUTHOR

Fayland Lam <fayland@gmail.com>

=cut

1;
