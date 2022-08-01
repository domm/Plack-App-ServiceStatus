package Plack::App::ServiceStatus::DBIxConnector;

# ABSTRACT: Check DBIx::Connector connection

# VERSION

use 5.018;
use strict;
use warnings;

sub check {
    my ( $class, $args ) = @_;
    $args = [$args] unless ref($args) eq 'ARRAY';

    my $conn  = $args->[0];
    my $query = $args->[1] || 'select 1';

   my $rv = $conn->run(sub {
        my $dbh = shift;
        my $sth = $dbh->prepare($query);
        my $ok = $sth->fetchrow_array;
        return 'ok' if $ok == 1;
        return 'nok', "got: $ok";
    });

    return $rv;
}

1;

__END__

=head1 SYNOPSIS

  my $conn       = DBIx::Connector->new( ... );
  my $status_app = Plack::App::ServiceStatus->new(
      app  => 'your app',
      DBIxConnector => $conn
  );

=head1 CHECK

Uses C<< DBIx::Connector->run >> to execute a query, per default
C<select 1;>. This query has to return C<1> to indicate that
everything is ok.

You can pass another query when loading C<Plack::App::ServiceStatus>:

  my $status_app = Plack::App::ServiceStatus->new(
      app           => 'your app',
      DBIxConnector => [ $conn, '
        SELECT CASE
            WHEN count(*) > 0 THEN 1
            ELSE 0
        END
        FROM some_table'
      ],
  );

