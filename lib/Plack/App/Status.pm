package Plack::App::Status;
use 5.018;
use strict;
use warnings;

our $VERSION = '0.900';

# ABSTRACT: Check and report status of various services needed by your app

use base 'Class::Accessor::Fast';
__PACKAGE__->mk_accessors(qw(app checks));

use Try::Tiny;
use Plack::Response;
use JSON::MaybeXS;
use Module::Runtime qw(use_module);
use Log::Any qw($log);

my $startup = time();

sub new {
    my ( $class, %args ) = @_;
    my $app = delete $args{app};
    my @checks;
    while ( my ( $key, $value ) = each %args ) {
        my $module;
        if ($key =~ /^\+/) {
            $module = $key;
            $module=~s/^\+//;
        }
        else {
            $module = 'Plack::App::Status::'.$key;
        }
        try {
            use_module($module);
            push(
                @checks,
                {   class => $module,
                    name  => $key,
                    args  => $value
                }
            );
        }
        catch {
            $log->errorf("%s: cannot init %s: %s",__PACKAGE__, $module, $_);
        };
    }

    return bless {
        app    => $app,
        checks => \@checks
    }, $class;
}

sub to_app {
    my $self = shift;

    my $app = sub {
        my $env = shift;

        my $json = {
            app        => $self->app,
            started_at => $startup,
            uptime     => time() - $startup,
        };

        my @results = (
            {   name   => $self->app,
                status => 'ok',
            }
        );

        foreach my $check ( @{ $self->checks } ) {
            my ( $status, $message ) = try {
                return $check->{class}->check($check->{args});
            }
            catch {
                return 'nok', "$_";
            };
            my $result = {
                name   => $check->{name},
                status => $status,
            };
            $result->{message} = $message if ($message);

            push( @results, $result );
        }
        $json->{checks} = \@results;

        return Plack::Response->new( 200,
            [ 'Content-Type', 'application/json' ],
            encode_json($json) )->finalize;
    };
    return $app;
}

1;
__END__

=head1 SYNOPSIS

  # using Plack::Builder with Plack::App::URLMap
  use Plack::Builder;
  use Plack::App::Status;

  my $status_app = Plack::App::Status->new(
      app           => 'your app',
      DBIC          => $schema,
      Elasticsearch => $es, # instance of Search::Elasticsearch
  );

  builder {
    mount "/_status" => $status_app;
    mount "/" => $your_app;
  };


  # using OX
  router as {
      mount '/_status' => 'Plack::App::Status' => (
          app              => literal(__PACKAGE__),
          Redis            => 'redis',
          '+MyApp::Status' => literal("foo"),
      );
      route '/some/endpoint' => 'some_controller.some_action';
      # ...
  };


  # checking the status
  curl http://localhost:3000/_status  | json_pp
  {
     "app" : "Your app",
     "started_at" : 1465823638,
     "uptime" : 42,
     "checks" : [
        {
           "status" : "ok",
           "name" : "Your app"
        },
        {
           "name" : "Elasticsearch",
           "status" : "ok"
        },
        {
           "name" : "DBIC",
           "status" : "ok"
        }
     ]
  }

=head1 DESCRIPTION

C<Plack::App::Status> implements a small
L<Plack|https://metacpan.org/pod/Plack> application that you can use
to get some status info on your application and the services needed by
it.

You can then use some monitoring software to periodically check if
your app is running and has access to all needed services.

=head2 Checks

The following checks are currently available:

=over

=item * L<Plack::App::Status::DBIC>

=item * L<Plack::App::Status::Redis>

=item * L<Plack::App::Status::Elasticsearch>

=back

Each check consists of a C<name> and a C<status>. The status can be
C<ok> or C<nok>. A check might also contain a C<message>, which should
be some description of the error or problem if the status is C<nok>.

You can add your own checks by specifying a name starting with a C<+>
sign, for example C<+My::App::SomeStatusCheck>.

=head2 Weirdness

The slightly strange way C<Plack::App::Status> is initiated is caused
by the way L<OX|https://metacpan.org/pod/OX> works.

C<Plack::App::Status> is B<not> implemented as a middleware on
purpose. While middlewares are great for a lot of use cases, I think
that here an embedded app is the better fit.

=head1 TODO

=over

=item * proper documentation

=item * tests

=item * make sure the app is only initiated once when running in OX

=back

=head1 THANKS

Thanks to

=over

=item *

L<validad.com|http://www.validad.com/> for funding the
development of this code.

=back

