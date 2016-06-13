#!/usr/bin/perl
use Test::More;
use lib 'lib';
use Module::Pluggable search_path => [ 'Plack::App::Status' ];

require_ok( $_ ) for sort 'Plack::App::Status', __PACKAGE__->plugins;

done_testing();
