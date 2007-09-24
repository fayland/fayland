package Foorum::ExternalUtils;

use strict;
use warnings;
use FindBin qw/$Bin/;
use YAML qw/LoadFile/;
use Foorum::Schema;
use base 'Exporter';
use vars qw/@EXPORT_OK $config $schema/;
@EXPORT_OK = qw/
    config
    schema
/;

sub config {
    
    return $config if ($config);
    
    $config = LoadFile("$Bin/../../foorum.yml");
    my $extra_config = LoadFile("$Bin/../../foorum_local.yml");
    $config = { %$config, %$extra_config };
    return $config;
}

sub schema {
    
    return $schema if ($schema);
    $config = config() unless ($config);
    
    $schema = Foorum::Schema->connect(
        $config->{dsn},
        $config->{dsn_user},
        $config->{dsn_pwd},
        { AutoCommit => 1, RaiseError => 1, PrintError => 1 },
    );
    return $schema;
}

1;
