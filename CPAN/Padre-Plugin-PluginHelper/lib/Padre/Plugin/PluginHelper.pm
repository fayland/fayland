package Padre::Plugin::PluginHelper;

use warnings;
use strict;

our $VERSION = '0.06';

use File::Basename ();
use File::Spec ();
use Wx ':everything';
use Wx::Menu ();
use Padre::Util ();

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
    unless ( $plugin_name =~ /^\w+/ ) {
        $self->error("Unknow Plugin");
    }
    
    my %plugins = %{ Padre->ide->plugin_manager->plugins };
    unless ( exists $plugins{$plugin_name} ) {
        $self->error("Unknow Plugin");
    }
    
    _reload_x_plugins( $self, $plugin_name );
}

sub _reload_x_plugins {
    my ( $self, $range ) = @_;
    
    my %plugins = %{ Padre->ide->plugin_manager->plugins };
    $self->{menu}->{plugin} = Wx::Menu->new;
    foreach my $name ( sort keys %plugins ) {
        # reload the module
        if ( $range eq 'all' or $range eq $name ) {
            delete $INC{"Padre/Plugin/${name}.pm"};
            eval "use Padre::Plugin::$name;"; ## no critic
            if ( $@ ) {
                warn "Error when calling plugin 'Padre::Plugin::$name' $@";
                next;
            }
        }
                
        # create menu
        my @menu    = eval { $plugins{$name}->menu };
        if ( $@ ) {
            warn "Error when calling menu for plugin '$name' $@";
            next;
        }
        my $menu_items = $self->{menu}->add_plugin_menu_items(\@menu);
        $self->{menu}->{plugin}->Append( -1, $name, $menu_items );
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
	$default_dir =~ s/Padre[\\\/]Plugin([\\\/]|$)//;
	
	unshift @INC, $default_dir unless ($INC[0] eq $default_dir);
	
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
