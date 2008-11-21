package Google::Gmail;

use warnings;
use strict;

our $VERSION = '0.01';

use LWP::UserAgent;
use HTTP::Request;

#########################
# from lgconstants.py
#########################
our $URL_LOGIN = 'https://www.google.com/accounts/ServiceLoginBoxAuth';
our $URL_GMAIL = 'https://mail.google.com/mail/';
our $GMAIL_URL_LOGIN = "https://www.google.com/accounts/ServiceLoginBoxAuth";
our $GMAIL_URL_GMAIL = "https://mail.google.com/mail/?ui=1&";

# Constants with names not from the Gmail Javascript:
our $U_SAVEDRAFT_VIEW = 'sd';
our $D_DRAFTINFO = 'di';
# NOTE: All other DI_* field offsets seem to match the MI_* field offsets
our $DI_BODY = 19;

our $versionWarned = 0; # If the Javascript version is different have we
                        # warned about it?

our $js_version = '44f09303f2d4f76f';
our $D_VERSION = "v";
our $D_QUOTA = "qu";
our $D_DEFAULTSEARCH_SUMMARY = "ds";
our $D_THREADLIST_SUMMARY = "ts";
our $D_THREADLIST_END = "te";
our $D_THREAD = "t";
our $D_CONV_SUMMARY = "cs";
our $D_CONV_END = "ce";
our $D_MSGINFO = "mi";
our $D_MSGBODY = "mb";
our $D_MSGATT = "ma";
our $D_COMPOSE = "c";
our $D_CONTACT = "co";
our $D_CATEGORIES = "ct";
our $D_CATEGORIES_COUNT_ALL = "cta";
our $D_ACTION_RESULT = "ar";
our $D_SENDMAIL_RESULT = "sr";
our $D_PREFERENCES = "p";
our $D_PREFERENCES_PANEL = "pp";
our $D_FILTERS = "fi";
our $D_GAIA_NAME = "gn";
our $D_INVITE_STATUS = "i";
our $D_END_PAGE = "e";
our $D_LOADING = "l";
our $D_LOADED_SUCCESS = "ld";
our $D_LOADED_ERROR = "le";
our $D_QUICKLOADED = "ql";
our $QU_SPACEUSED = 0;
our $QU_QUOTA = 1;
our $QU_PERCENT = 2;
our $QU_COLOR = 3;
our $TS_START = 0;
our $TS_NUM = 1;
our $TS_TOTAL = 2;
our $TS_ESTIMATES = 3;
our $TS_TITLE = 4;
our $TS_TIMESTAMP = 5 + 1;
our $TS_TOTAL_MSGS = 6 + 1;
our $T_THREADID = 0;
our $T_UNREAD = 1;
our $T_STAR = 2;
our $T_DATE_HTML = 3;
our $T_AUTHORS_HTML = 4;
our $T_FLAGS = 5;
our $T_SUBJECT_HTML = 6;
our $T_SNIPPET_HTML = 7;
our $T_CATEGORIES = 8;
our $T_ATTACH_HTML = 9;
our $T_MATCHING_MSGID = 10;
our $T_EXTRA_SNIPPET = 11;
our $CS_THREADID = 0;
our $CS_SUBJECT = 1;
our $CS_TITLE_HTML = 2;
our $CS_SUMMARY_HTML = 3;
our $CS_CATEGORIES = 4;
our $CS_PREVNEXTTHREADIDS = 5;
our $CS_THREAD_UPDATED = 6;
our $CS_NUM_MSGS = 7;
our $CS_ADKEY = 8;
our $CS_MATCHING_MSGID = 9;
our $MI_FLAGS = 0;
our $MI_NUM = 1;
our $MI_MSGID = 2;
our $MI_STAR = 3;
our $MI_REFMSG = 4;
our $MI_AUTHORNAME = 5;
our $MI_AUTHORFIRSTNAME = 6; # ? -- Name supplied by rj
our $MI_AUTHOREMAIL = 6 + 1;
our $MI_MINIHDRHTML = 7 + 1;
our $MI_DATEHTML = 8 + 1;
our $MI_TO = 9 + 1;
our $MI_CC = 10 + 1;
our $MI_BCC = 11 + 1;
our $MI_REPLYTO = 12 + 1;
our $MI_DATE = 13 + 1;
our $MI_SUBJECT = 14 + 1;
our $MI_SNIPPETHTML = 15 + 1;
our $MI_ATTACHINFO = 16 + 1;
our $MI_KNOWNAUTHOR = 17 + 1;
our $MI_PHISHWARNING = 18 + 1;
our $A_ID = 0;
our $A_FILENAME = 1;
our $A_MIMETYPE = 2;
our $A_FILESIZE = 3;
our $CT_NAME = 0;
our $CT_COUNT = 1;
our $AR_SUCCESS = 0;
our $AR_MSG = 1;
our $SM_COMPOSEID = 0;
our $SM_SUCCESS = 1;
our $SM_MSG = 2;
our $SM_NEWTHREADID = 3;
our $CMD_SEARCH = "SEARCH";
our $ACTION_TOKEN_COOKIE = "GMAIL_AT";
our $U_VIEW = "view";
our $U_PAGE_VIEW = "page";
our $U_THREADLIST_VIEW = "tl";
our $U_CONVERSATION_VIEW = "cv";
our $U_COMPOSE_VIEW = "cm";
our $U_PRINT_VIEW = "pt";
our $U_PREFERENCES_VIEW = "pr";
our $U_JSREPORT_VIEW = "jr";
our $U_UPDATE_VIEW = "up";
our $U_SENDMAIL_VIEW = "sm";
our $U_AD_VIEW = "ad";
our $U_REPORT_BAD_RELATED_INFO_VIEW = "rbri";
our $U_ADDRESS_VIEW = "address";
our $U_ADDRESS_IMPORT_VIEW = "ai";
our $U_SPELLCHECK_VIEW = "sc";
our $U_INVITE_VIEW = "invite";
our $U_ORIGINAL_MESSAGE_VIEW = "om";
our $U_ATTACHMENT_VIEW = "att";
our $U_DEBUG_ADS_RESPONSE_VIEW = "da";
our $U_SEARCH = "search";
our $U_INBOX_SEARCH = "inbox";
our $U_STARRED_SEARCH = "starred";
our $U_ALL_SEARCH = "all";
our $U_DRAFTS_SEARCH = "drafts";
our $U_SENT_SEARCH = "sent";
our $U_SPAM_SEARCH = "spam";
our $U_TRASH_SEARCH = "trash";
our $U_QUERY_SEARCH = "query";
our $U_ADVANCED_SEARCH = "adv";
our $U_CREATEFILTER_SEARCH = "cf";
our $U_CATEGORY_SEARCH = "cat";
our $U_AS_FROM = "as_from";
our $U_AS_TO = "as_to";
our $U_AS_SUBJECT = "as_subj";
our $U_AS_SUBSET = "as_subset";
our $U_AS_HAS = "as_has";
our $U_AS_HASNOT = "as_hasnot";
our $U_AS_ATTACH = "as_attach";
our $U_AS_WITHIN = "as_within";
our $U_AS_DATE = "as_date";
our $U_AS_SUBSET_ALL = "all";
our $U_AS_SUBSET_INBOX = "inbox";
our $U_AS_SUBSET_STARRED = "starred";
our $U_AS_SUBSET_SENT = "sent";
our $U_AS_SUBSET_DRAFTS = "drafts";
our $U_AS_SUBSET_SPAM = "spam";
our $U_AS_SUBSET_TRASH = "trash";
our $U_AS_SUBSET_ALLSPAMTRASH = "ast";
our $U_AS_SUBSET_READ = "read";
our $U_AS_SUBSET_UNREAD = "unread";
our $U_AS_SUBSET_CATEGORY_PREFIX = "cat_";
our $U_THREAD = "th";
our $U_PREV_THREAD = "prev";
our $U_NEXT_THREAD = "next";
our $U_DRAFT_MSG = "draft";
our $U_START = "start";
our $U_ACTION = "act";
our $U_ACTION_TOKEN = "at";
our $U_INBOX_ACTION = "ib";
our $U_MARKREAD_ACTION = "rd";
our $U_MARKUNREAD_ACTION = "ur";
our $U_MARKSPAM_ACTION = "sp";
our $U_UNMARKSPAM_ACTION = "us";
our $U_MARKTRASH_ACTION = "tr";
our $U_ADDCATEGORY_ACTION = "ac_";
our $U_REMOVECATEGORY_ACTION = "rc_";
our $U_ADDSTAR_ACTION = "st";
our $U_REMOVESTAR_ACTION = "xst";
our $U_ADDSENDERTOCONTACTS_ACTION = "astc";
our $U_DELETEMESSAGE_ACTION = "dm";
our $U_DELETE_ACTION = "dl";
our $U_EMPTYSPAM_ACTION = "es_";
our $U_EMPTYTRASH_ACTION = "et_";
our $U_SAVEPREFS_ACTION = "prefs";
our $U_ADDRESS_ACTION = "a";
our $U_CREATECATEGORY_ACTION = "cc_";
our $U_DELETECATEGORY_ACTION = "dc_";
our $U_RENAMECATEGORY_ACTION = "nc_";
our $U_CREATEFILTER_ACTION = "cf";
our $U_REPLACEFILTER_ACTION = "rf";
our $U_DELETEFILTER_ACTION = "df_";
our $U_ACTION_THREAD = "t";
our $U_ACTION_MESSAGE = "m";
our $U_ACTION_PREF_PREFIX = "p_";
our $U_REFERENCED_MSG = "rm";
our $U_COMPOSEID = "cmid";
our $U_COMPOSE_MODE = "cmode";
our $U_COMPOSE_SUBJECT = "su";
our $U_COMPOSE_TO = "to";
our $U_COMPOSE_CC = "cc";
our $U_COMPOSE_BCC = "bcc";
our $U_COMPOSE_BODY = "body";
our $U_PRINT_THREAD = "pth";
our $CONV_VIEW = "conv";
our $TLIST_VIEW = "tlist";
our $PREFS_VIEW = "prefs";
our $HIST_VIEW = "hist";
our $COMPOSE_VIEW = "comp";
our $HIDDEN_ACTION = 0;
our $USER_ACTION = 1;
our $BACKSPACE_ACTION = 2;

# TODO: Get these on the fly?
our @STANDARD_FOLDERS = ( $U_INBOX_SEARCH, $U_STARRED_SEARCH,
						  $U_ALL_SEARCH,  $U_DRAFTS_SEARCH,
						  $U_SENT_SEARCH, $U_SPAM_SEARCH );

# Perl contants
our $USER_AGENT = "User-Agent: Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US; rv:1.7.8) Gecko/20050511 Firefox/1.0.4";

sub new {
	my ( $class, $user, $pass, $domain ) = @_;

	my $self = bless { _user => $user, _pass => $pass, _domain => $domain }, $class;
	
	if ( $self->{domain} ) {
		$URL_LOGIN = "https://www.google.com/a/" + self.domain + "/LoginAction2";
        $URL_GMAIL = "http://mail.google.com/a/" + self.domain + "/?ui=1&";
	} else {
		$URL_LOGIN = $GMAIL_URL_LOGIN;
        $URL_GMAIL = $GMAIL_URL_GMAIL;
	}
	
	$self->{_ua} = LWP::UserAgent->new( agent => $USER_AGENT, keep_alive => 1 );
	$self->{_cookies} = { };
	
	return $self;
}

sub login {
	my ( $self ) = @_;
	
	my $user = $self->{_user};
	my $pass = $self->{_pass};
	my $domain = $self->{_domain};
	
	my $data;
	if ( $domain ) {
		$data = {
			'continue' => $URL_GMAIL,
            'at'       => 'null',
            'service'  => 'mail',
            'Email'    => $user,
            'Passwd'   => $pass,
		};
	} else {
		$data = {
			'continue' => $URL_GMAIL,
            'Email'    => $user,
            'Passwd'   => $pass,
		};
	}
	
	my $req = HTTP::Request->new( POST => $URL_LOGIN );
	$req->header( 'Host' => 'www.google.com' );
    $req->header( 'Cookie' => $self->{_cookie} );
    my ( $cookie );

    $req->content( $data );

    my $res = $self->{_ua}->request( $req );

    if ( !$res->is_success() ) {
        $self->_error( "Error: Could not login with those credentials - the request was not a success\n" );
        $self->_error( "  Additionally, HTTP error: " . $res->status_line . "\n" );
        return;
    }

	my $content = $self->{_ua}->content();
	unless ( $domain ) {
		if ( $content =~ /CheckCookie\?continue=([^"\']+)/ ) {
			$req = HTTP::Request->new( GET => $1 );
			$req->header( 'Host' => 'www.google.com' );
			$req->header( 'Cookie' => $self->{_cookie} );
			$res = $self->{_ua}->request( $req );
			$content = $self->{_ua}->content();
		} else {
			$self->_error( "Login failed. (Wrong username/password?" );
		}
	}
	
	return $content;
}

sub getMessagesByFolder {
	my ( $self, $folderName ) = @_;
	
	$self->_parseThreadSearch( $folderName );	
}

sub _parseThreadSearch {
	my ( $self, $searchType ) = @_;
	
	my $start = 0;
    my $tot = 0;
    my @threadsInfo;
    
	my $items = $self->_parseSearchResult( $searchType, $start );
}

sub _parseSearchResult {
	my ( $self, $searchType, $start ) = @_;
	
	my $data = {
		$U_SEARCH => $searchType,
        $U_START  => $start,
        $U_VIEW   => $U_THREADLIST_VIEW,
	};
	$self->_parsePage($self->_buildURL($data));
}

sub _parsePage {
	my ( $self, $pageContent ) = @_;
	
	my @lines = split("\n", $pageContent);
	
	# data = '\n'.join([x for x in lines if x and x[0] in ['D', ')', ',', ']']])
	# next TODO
}

sub _error {
	my ( $self, $msg ) = @_;
	
	$self->{_error} = 1;
	$self->{_err_str} .= $msg;
    return $self->{_err_str};
}

1;
__END__

=head1 NAME

Google::Gmail - Gmail access via Perl

=head1 SYNOPSIS

    use Google::Gmail;

    my $ga = Google::Gmail->new("google@gmail.com", "mymailismypass");
    $ga->login();
    my @folder = $ga->getMessagesByFolder('inbox');
	
	foreach my $thread ( @folder ) {
		print $thread->id, $thread->len, $thread->subject, "\n";
		foreach my $msg ( @{ $thread->msgs } ) {
			print "  ", $msg->id, $msg->number, $msg->subject, "\n";
			print $msg->source, "\n";
		}
	}

=head1 DESCRIPTION

Gmail is L<https://mail.google.com/mail/>

=over 4

=item libgmail

libgmail ¡ª Python binding for Google's Gmail service

L<http://sourceforge.net/projects/libgmail/>

=back

=head1 AUTHOR

Fayland Lam, C<< <fayland at gmail.com> >>

=head1 COPYRIGHT & LICENSE

Copyright 2008 Fayland Lam, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut
