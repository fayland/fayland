#!/usr/bin/perl

use strict;
use warnings;

use inc::Module::Install;

name 'Task-Fayland';
all_from 'lib/Task/Fayland.pm';
author 'Fayland Lam <fayland@gmail.com>';
license 'perl';

if ($^O eq 'MSWin32') {
  system("ppm install Crypt-SSLeay");
}

requires( 'CPAN',                         '1.87' );
requires( 'CPAN::Reporter',               undef );        # be a CPAN tester
requires( 'local::lib',                   undef );
requires( 'Scalar::Util',                 '1.18' );
requires( 'List::Util',                   undef );
requires( 'List::MoreUtils',              undef );
requires( 'File::Next',                   undef );
requires( 'DateTime',                     '0.41' );
requires( 'Test::Pod',                    undef );
requires( 'WWW::Mechanize',               undef );
requires( 'Email::Send',                  undef );
requires( 'Moose',                        '0.35' );
requires( 'PPI',                          undef );
requires( 'Catalyst',                     '5.7014' );     # work
requires( 'DBIx::Class',                  '0.08010' );    # $$$$
requires( 'Template',                     '2.20' );       # @_@
requires( 'Template::Plugin::FillInForm', undef );
requires( 'Perl::Critic',                 '1.080' );      # perlcritic
requires( 'Perl::Tidy',                   undef );        # perltidy
requires( 'HTML::TokeParser::Simple',     undef );
requires( 'Sphinx::Search',               undef );        # sphinxsearch.com

# all my modules
requires('Acme::CPANAuthors::Chinese');
requires('Acme::PlayCode');
requires('Business::CN::IdentityCard');
requires('Catalyst::Action::Fixup::XHTML');
requires('Catalyst::Authentication::Store::FromSub::Hash');
requires('Catalyst::Model::DBIC::Schema::QueryLog');
requires('Catalyst::Plugin::PickComponents');
requires('Date::Holidays::CN');
requires('DayDayUp');
requires('Email::Send::SMTP::TLS');    # send mail through gmail
requires('Email::Sender::Transport::SMTP::TLS');
requires('Google::Code::Upload');
requires('HTTP::Session::Store::DBI');
requires('IRC::Bot::Log::Extended');
requires('JavaScript::Beautifier');
requires('Lingua::Han::Cantonese');
requires('Lingua::Han::PinYin');
requires('Lingua::Han::Stroke');
requires('Lingua::Han::Utils');
requires('Locale::Country::Multilingual');
requires('Mail::Mailer::smtp_auth');
requires('MojoX::Fixup::XHTML');
requires('MooseX::Control');
requires('MooseX::Dumper');
requires('MooseX::Types::IO');
requires('MySQL::SlowLog::Filter');
requires('Perlbal::Control');
requires('Pod::From::GoogleWiki');
requires('Pod::Simple::Wiki::Googlecode');
requires('Sphinx::Control');
requires('Template::Plugin::HtmlToText');
requires('Text::GooglewikiFormat');
requires('TheSchwartz::Moosified');
requires('WWW::Conatct');
requires('YAML::LoadURI');
requires('Foorum');

feature 'install Padre stuff?',
  -default                       => 0,
  'Padre::Plugin::AcmePlayCode'  => 0,
  'Padre::Plugin::Alarm'         => 0,
  'Padre::Plugin::CSS'           => 0,
  'Padre::Plugin::Encrypt'       => 0,
  'Padre::Plugin::HTML'          => 0,
  'Padre::Plugin::HTMLExport'    => 0,
  'Padre::Plugin::JavaScript'    => 0,
  'Padre::Plugin::SpellCheck'    => 0,
  'Padre::Plugin::ViewInBrowser' => 0,
  'Padre::Plugin::XML'           => 0,
  'Task::Padre::Plugins'         => 0,
  'Task::Padre::Plugin::Deps'    => 0;

auto_install;

WriteAll;

1;
