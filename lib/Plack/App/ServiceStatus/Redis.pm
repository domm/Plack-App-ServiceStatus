package Plack::App::ServiceStatus::Redis;

# ABSTRACT: Check Redis connection

# VERSION

use 5.018;
use strict;
use warnings;

sub check {
    my ( $class, $redis ) = @_;

    my $rv = $redis->ping;
    return 'ok' if $rv eq 'PONG';
    return 'nok', "got: $rv";
}

1;

__END__

=head1 SYNOPSIS

  my $redis      = Redis->new;
  my $status_app = Plack::App::ServiceStatus->new(
      app   => 'your app',
      Redis => $redis,
  );

=head1 CHECK

Calls C<ping> on the C<$redis> object.

