package Padre::Plugin::PluginHelper;

use warnings;
use strict;

our $VERSION = '0.09';

use File::Basename ();
use File::Spec ();
use Wx ':everything';
use Wx::Menu ();
use Padre::Util ();
use Module::Refresh;

my @menu = (
    ['Reload All Plugins', \&reload_plugins ],
    ['Reload A Plugin',    \&reload_a_plugin],
    ['Test A Plugin From Local Dir', \&test_a_plugin],    
);

sub menu {
    my ($self) = @_;
    return @menu;
}

sub reload_plugins {
    my ( $self ) = @_;

    _reload_x_plugins( $self, 'all' );
}

sub reload_a_plugin {
    my ( $self ) = @_;
    
    require Padre::Wx::History::TextDialog;
    my $dialog = Padre::Wx::History::TextDialog->new(
        $self, 'Plugin name:', 'Reload A Plugin', 'Reload_plugin_name',
    );
    if ( $dialog->ShowModal == Wx::wxID_CANCEL ) {
        return;
    }
    my $plugin_name = $dialog->GetValue;
    $dialog->Destroy;
    unless ( defined $plugin_name ) {
        return;
    }
    unless ( $plugin_name =~ /^[\w\:]+/ ) {
        $self->error('Unknow Plugin');
    }
    
    my %plugins = %{ Padre->ide->plugin_manager->plugins };
    unless ( exists $plugins{$plugin_name} ) {
        $self->error('Unknow Plugin');
    }
    
    _reload_x_plugins( $self, $plugin_name );
}

sub _reload_x_plugins {
    my ( $self, $range ) = @_;
    
    my $refresher = new Module::Refresh;

    my %plugins = %{ Padre->ide->plugin_manager->plugins };
    foreach my $name ( sort keys %plugins ) {
        # avoid warnings like "Padre::Plugin::PluginHelper::_reload_x_plugins: Can't undef active subroutine at
        # C:/strawberry/perl/site/lib/Module/Refresh.pm line 181."
        if ( $name eq 'PluginHelper' ) {
			next; # no warnings; # no reload this PluginHelper
        }
    
        # reload the module
        if ( $range eq 'all' or $range eq $name ) {
            my $file_in_INC = "Padre/Plugin/${name}.pm";
            $file_in_INC =~ s/\:\:/\//;
            $refresher->refresh_module($file_in_INC);
        }
    }
    
    # re-create menu, # coped from Padre::Wx::Menu
    $self->{menu}->{plugin} = Wx::Menu->new;
    foreach my $name ( sort keys %plugins ) {
        my @menu    = eval { $plugins{$name}->menu };
        if ( $@ ) {
            warn "Error when calling menu for plugin '$name' $@";
            next;
        }
        my $menu_items = $self->{menu}->add_plugin_menu_items(\@menu);
        my $menu_name  = eval { $plugins{$name}->menu_name };
        if (not $menu_name) {
            $menu_name = $name;
            $menu_name =~ s/::/ /;
        }
        $self->{menu}->{plugin}->Append( -1, $menu_name, $menu_items );
    }
    $self->{menu}->{wx}->Replace(5, $self->{menu}->{plugin},   "Pl&ugins");
    
    $self->{menu}->refresh;
}

sub test_a_plugin {
    my ( $self ) = @_;
    
    my $manager = Padre->ide->plugin_manager;
    my $plugin_config = $manager->plugin_config('PluginHelper');
    my $last_filename = $plugin_config->{last_filename};
    $last_filename  ||= $self->selected_filename;
    my $default_dir;
    if ($last_filename) {
        $default_dir = File::Basename::dirname($last_filename);
    }
    my $dialog = Wx::FileDialog->new(
        $self,
        'Open file',
        $default_dir,
        "",
        "*.*",
        Wx::wxFD_OPEN,
    );
    unless ( Padre::Util::WIN32 ) {
        $dialog->SetWildcard("*");
    }
    if ( $dialog->ShowModal == Wx::wxID_CANCEL ) {
        return;
    }
    my $filename = $dialog->GetFilename;
    $default_dir = $dialog->GetDirectory;
    
    my $file = File::Spec->catfile($default_dir, $filename);
    
    # save into plugin for next time
    $plugin_config->{last_filename} = $file;
    
    $filename    =~ s/\.pm$//; # remove last .pm
    $filename    =~ s/[\\\/]/\:\:/;
    $default_dir =~ s/Padre[\\\/]Plugin([\\\/]|$)//;
    
    unshift @INC, $default_dir unless ($INC[0] eq $default_dir);
    my $plugins = Padre->ide->plugin_manager->plugins;
    $plugins->{$filename} = "Padre::Plugin::$filename";
    eval { require $file; 1 } or warn $@; # load for Module::Refresh
    
    # reload all means rebuild the 'Plugins' menu
    _reload_x_plugins( $self, 'all' );
}

1;
__END__

=head1 NAME

Padre::Plugin::PluginHelper - make building Padre plugin easy

=head1 SYNOPSIS

    $>padre
    Plugins -> PluginHelper -> *

=head1 DESCRIPTION

It's dirty, it's ugly, but it works!

=head2 Reload All Plugins

it is very useful when you develop the plugin. you don't need to restart padre, u just click this.

all the modules will be reloaded.

=head2 Reload A Plugin

instead reload all, just reload the one you are changing.

=head2 Test A Plugin From Local Dir

When you develop a new plugin, try this.

it B<unshift> the plugin lib dir to @INC then tries to reload all plugins (rebuild the menu)

=head1 AUTHOR

Fayland Lam, C<< <fayland at gmail.com> >>

=head1 COPYRIGHT & LICENSE

Copyright 2008 Fayland Lam, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut
