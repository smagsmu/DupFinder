package Bugzilla::Extension::DupFinder::WebService::Bug;

use strict;
use warnings;
use base qw(Bugzilla::WebService::Bug);
use Bugzilla::Constants;
use Bugzilla::Error;
use Bugzilla::WebService::Util qw(validate);
use Bugzilla::Extension::DupFinder::Bug;

sub possible_duplicates {
    my ($self, $params) = validate(@_, 'product');
    my $user = Bugzilla->user;

    Bugzilla->switch_to_shadow_db();

    my @products;
    foreach my $name (@{ $params->{'product'} || [] }) {
        my $object = $user->can_enter_product($name, THROW_ERROR);
        push(@products, $object);
    }

    my $possible_dupes = Bugzilla::Extension::DupFinder::Bug->possible_duplicates(
        { summary => $params->{summary}, description => $params->{description}, products => \@products,
          limit   => $params->{limit} });
    my @hashes = map { $self->_bug_to_hash($_, $params) } @$possible_dupes;
    return { bugs => \@hashes };
}

1;
