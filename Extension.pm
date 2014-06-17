package Bugzilla::Extension::DupFinder;

use strict;
use base qw(Bugzilla::Extension);
use Data::Dumper;

our $VERSION = '1.0';


sub webservice {
    my ($self, $args) = @_;

    my $dispatch = $args->{dispatch};
    $dispatch->{'DupFinder.Bug'} = "Bugzilla::Extension::DupFinder::WebService::Bug";
}

__PACKAGE__->NAME;
