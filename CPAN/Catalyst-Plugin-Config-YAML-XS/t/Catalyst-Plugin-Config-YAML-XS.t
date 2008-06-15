package Foo;

use Test::More tests => 2;

BEGIN { use_ok('Catalyst', 'Config::YAML::XS') };

Foo->config(
	'home' => 't', 
);

Foo->setup;

is(Foo->config->{'blurp'}, 'moose', 'main config');
