package Bugzilla::Extension::DupFinder;

use strict;
use constant NAME => 'DupFinder';
use constant REQUIRED_MODULES => [
    {
        package => 'Text-Document',
        module  => 'Text::Document',
        version => 0,
    },
    {
        package => 'Lingua-StopWords',
        module  => 'Lingua::StopWords',
        version => 0,
    },
    {
        package => 'Lingua-Stem',
        module  => 'Lingua::Stem',
        version => 0,
    },
    {
        package => 'JSON-RPC',
        module  => 'JSON::RPC',
        version => 0,
    },
];

__PACKAGE__->NAME;
