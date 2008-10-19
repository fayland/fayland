# mostly copied from rjbs's Task-BeLike-RJBS

# You don't need to smoke my bundle, but thanks! -- rjbs, 2008-04-12
exit 0 if $ENV{AUTOMATED_TESTING};

use 5.008; # why would I use anything less?
use strict;
use warnings;

use inc::Module::Install;

name        ('Task-BeLike-FAYLAND');
all_from    ('lib/Task/BeLike/FAYLAND.pm');
license     ('perl');
extra_tests;

  requires('CPAN',                           '1.87'    );
  requires('CPAN::Reporter',                 undef     ); # be a CPAN tester
  requires('local::lib',                     undef     );
  requires('Scalar::Util',                   '1.18'    );
  requires('List::Util',                     undef     );
  requires('List::MoreUtils',                undef     );
  requires('File::Next',                     undef     );
  requires('DateTime',                       '0.41'    );
  requires('Test::Pod',                      undef     );
  requires('WWW::Mechanize',                 undef     );
  requires('Email::Send',                    undef     );
  requires('Moose',                          '0.35'    );
  requires('PPI',                            undef     );
  requires('Catalyst',                       '5.7014'  ); # work
  requires('DBIx::Class',                    '0.08010' ); # $$$$
  requires('Template',                       '2.20'    ); # @_@
  requires('Template::Plugin::FillInForm',   undef     );
  requires('Perl::Critic',                   '1.080'   ); # perlcritic
  requires('Perl::Tidy',                     undef     ); # perltidy
  requires('HTML::TokeParser::Simple',       undef     );
  requires('Sphinx::Search',                 undef     ); # sphinxsearch.com
  
  # all my modules
  requires('Acme::CPANAuthors::Chinese');
  requires('Acme::PlayCode');
  requires('Business::CN::IdentityCard');
  requires('Catalyst::Authentication::Store::FromSub::Hash');
  requires('Catalyst::Model::DBIC::Schema::QueryLog');
  requires('Catalyst::Plugin::CHI');
  requires('Catalyst::Plugin::Config::YAML::XS');
  requires('Catalyst::Plugin::PickComponents');
  requires('Date::Holidays::CN');
  requires('Email::Send::SMTP::TLS'); # send mail through gmail
  requires('Lingua::Han::Cantonese');
  requires('Lingua::Han::PinYin');
  requires('Lingua::Han::Stroke');
  requires('Lingua::Han::Utils');
  requires('Locale::Country::Multilingual');
  requires('Mail::Mailer::smtp_auth');
  requires('MooseX::TheSchwartz');
  requires('MooseX::Types::IO');
  requires('Pod::From::GoogleWiki');
  requires('Pod::Simple::Wiki::Googlecode');
  requires('POD2::CN');
  requires('MooseX::Control');
  requires('Sphinx::Control');
  requires('Perlbal::Control');
  requires('Template::Plugin::HtmlToText');
  requires('Text::GooglewikiFormat');
  requires('WWW::Conatct');
  requires('Foorum');

WriteAll;
