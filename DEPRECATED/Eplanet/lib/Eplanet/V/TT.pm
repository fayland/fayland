package Eplanet::V::TT;

use strict;
use Carp;
use base 'Catalyst::View::TT';
use Template::Constants qw( :debug );

__PACKAGE__->config->{POST_CHOMP} = 1;
__PACKAGE__->config->{PRE_CHOMP} = 1;
__PACKAGE__->config->{DEBUG} = DEBUG_PARSER | DEBUG_PROVIDER;
__PACKAGE__->config->{PRE_PROCESS} = 'header.tt';
__PACKAGE__->config->{EVAL_PERL} = 1;
__PACKAGE__->config->{CONTEXT} = undef;
#__PACKAGE__->config->{PLUGIN_BASE} = 'MyTemplate::Plugin::Filter';
#__PACKAGE__->config->{PLUGINS} = {
#	Textile => 'MyTemplate::Plugin::Filter::Textile',
#};

# mostly from Catalyst::View::TT, just add the function(build)
sub process {
    my ( $self, $c ) = @_;
    $c->res->headers->content_type('text/html;charset=utf8');
    my ($output, $filename);
    if ($c->stash->{build}) {
    	croak('Sorry, u forgot to set the $c->stash->{build_filename} !') unless ($c->stash->{build_filename});
    	$filename = $c->config->{build_root} . "/doodle/" . $c->stash->{build_filename} . ".html";
    	open(FH, ">$filename");
    	$output = *FH;
    }
    my $name = $c->stash->{template} || $c->req->match;
    unless ($name) {
        $c->log->debug('No template specified for rendering') if $c->debug;
        return 0;
    }
    $c->log->debug(qq/Rendering template "$name"/) if $c->debug;
    unless (
        $self->template->process(
            $name,
            {
                %{ $c->stash },
                base => $c->req->base,
                c    => $c,
                name => $c->config->{name}
            },
            \$output
        )
      )
    {
        my $error = $self->template->error;
        $error = qq/Couldn't render template "$error"/;
        $c->log->error($error);
        $c->error($error);
    }
    if ($c->stash->{build}) {
    	close(FH);
    	$c->res->output("Build <a href='$filename'>$filename</a> Okay!, Back to <a href='" . $c->req->base . "'>IndexPage</a>");
    } else {
    	$c->res->output($output);
    }
    return 1;
}


1;
