package Plack::App::ServiceStatus::DBIC;
use 5.018;
use strict;
use warnings;

our $VERSION = '0.900';

# ABSTRACT: Check DBIC connection

sub check {
    my ( $class, $args ) = @_;
    $args = [$args] unless ref($args) eq 'ARRAY';

    my $dbic  = $args->[0];
    my $query = $args->[1] || 'select 1';
    my $sth   = $dbic->storage->dbh->prepare($query);
    $sth->execute;
    my $ok = $sth->fetchrow_array;
    return 'ok' if $ok == 1;
    return 'nok', "got: $ok";
}

1;

