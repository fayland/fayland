package Foorum::ExternalUtils;

use strict;
use warnings;
use File::Spec;
use YAML qw/LoadFile/;
use Foorum::Schema;
use TheSchwartz;
use base 'Exporter';
use vars qw/@EXPORT_OK $config $schema $memcached $theschwartz/;
@EXPORT_OK = qw/
    config
    schema
    memcached
    theschwartz
/;

sub config {
    
    return $config if ($config);
    
    my (undef, $path) = File::Spec->splitpath(__FILE__);
    
    $config = LoadFile("$path/../../foorum.yml");
    my $extra_config = LoadFile("$path/../../foorum_local.yml");
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

sub memcached {
    
    return $memcached if ($memcached);
    $config = config() unless ($config);
    
    my $params = { %{ $config->{cache} } };
    $memcached = Cache::Memcached->new($params);
    return $memcached;
}

sub theschwartz {
    
    return $theschwartz if ($theschwartz);
    $config = config() unless ($config);
    
    my $theschwartz = TheSchwartz->new(
        databases => [ {
            dsn  => $config->{theschwartz_dsn},
            user => $config->{dsn_user},
            pass => $config->{dsn_pwd},
        } ],
        verbose => 1,
    );
    return $theschwartz;
}


1;
