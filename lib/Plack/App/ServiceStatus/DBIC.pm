package Plack::App::ServiceStatus::DBIC;

# ABSTRACT: Check DBIC connection

# VERSION

use 5.018;
use strict;
use warnings;

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

__END__

=head1 SYNOPSIS

  my $schema     = YourApp::Schema->connect( ... );
  my $status_app = Plack::App::ServiceStatus->new(
      app  => 'your app',
      DBIC => $schema,
  );

=head1 CHECK

Gets C<dbh> from the schema object and executes a query, per default
C<select 1;>. This query has to return C<1> to indicate that
everything is ok.

You can pass another query when loading C<Plack::App::ServiceStatus>:

  my $status_app = Plack::App::ServiceStatus->new(
      app           => 'your app',
      DBIC          => [ $schema, '
        SELECT CASE
            WHEN count(*) > 0 THEN 1
            ELSE 0
        END
        FROM some_table'
      ],
  );

