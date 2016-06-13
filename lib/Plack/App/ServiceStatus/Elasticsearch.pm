package Plack::App::ServiceStatus::Elasticsearch;
use 5.018;
use strict;
use warnings;

our $VERSION = '0.900';

# ABSTRACT: Check Elasticsearch connection

sub check {
    my ( $class, $es ) = @_;

    my $rv = $es->ping;
    return 'ok' if $rv == 1;
    return 'nok', "got: $rv";
}

1;
