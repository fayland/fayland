#!/usr/bin/perl

use strict;
use warnings;
use File::Next;

my @modules = @ARGV;

my $save_text; my @ex_modules;
foreach my $module (@modules) {
    my $file = find_module_place($module);
    unless ($file) {
        warn "$module is missing, please retry\n";
        next;
    }
    
    push @ex_modules, $module;
    
    # get all the sub-modules
    my @sub_modules_files = get_sub_modules($file);
    unshift @sub_modules_files, $file;
    
    # merge all files' source into a txt file
    foreach my $pm (@sub_modules_files) {
        open(my $fh, '<', $pm);
        local $/ = undef;
        my $text = <$fh>;
        close($fh);
        $save_text .= "=" x 50 . "\n$pm\n$text\n";
    }
}

if ($save_text) {
    my $file = join('-', @ex_modules);
    $file =~ s/\:\:/\_/isg;
    $file .= '.txt';
    open(my $fh, '>', $file);
    print $fh $save_text;
    close($fh);
    print "Done as $file\n";
}

sub find_module_place {
    my ($module) = @_;
    
    $module =~ s/\:\:/\//isg;
    $module .= '.pm';
    foreach my $dir (@INC) {
        return "$dir/$module" if (-e "$dir/$module");
    }
}

sub get_sub_modules {
    my ($module) = @_;
    
    my $dir = $module;
    $dir =~ s/\.pm/\//isg;

    my @modules;
    my $files = File::Next::files( $dir );
    while ( defined ( my $file = $files->() ) ) {
        push @modules, $file if ($file =~ /\.pm/);
    }

    return @modules;
}

1;