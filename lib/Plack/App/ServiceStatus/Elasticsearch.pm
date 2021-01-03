package Plack::App::ServiceStatus::Elasticsearch;

# ABSTRACT: Check Elasticsearch connection

# VERSION

use 5.018;
use strict;
use warnings;

sub check {
    my ( $class, $es ) = @_;

    my $rv = $es->ping;
    return 'ok' if $rv == 1;
    return 'nok', "got: $rv";
}

1;

__END__

=head1 SYNOPSIS

  my $es         = Search::Elasticsearch->new;
  my $status_app = Plack::App::ServiceStatus->new(
      app           => 'your app',
      Elasticsearch => $es,
  );

=head1 CHECK

Calls C<ping> on the C<$elasticsearch> object.

