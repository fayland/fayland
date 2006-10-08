use strict;
use Module::Build;

my $build = Module::Build->new(
    create_makefile_pl  => 'traditional',
    license            => 'perl',
    module_name        => 'Business::CN::IdentityCard',
    requires           => {
        'Date::Simple' => 0,
    	'Class::Accessor::Fast' => 0,
    },
);
$build->create_build_script;
