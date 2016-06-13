package Plack::App::Status::Redis;
use 5.018;
use strict;
use warnings;

our $VERSION = '0.900';

# ABSTRACT: Check Redis connection

sub check {
    my ( $class, $redis ) = @_;

    my $rv = $redis->ping;
    return 'ok' if $rv eq 'PONG';
    return 'nok', "got: $rv";
}

1;
