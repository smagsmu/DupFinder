package Bugzilla::Extension::DupFinder::Document;

use base qw(Text::Document);
use Lingua::Stem qw(stem_in_place);
use Lingua::StopWords qw( getStopWords );


sub ScanV
{
        my $self = shift;
        my ($text) = @_;
        my @words = split( /[^a-zA-Z0-9]+/, $text );
        @words = grep( /.+/, @words );
        if( $self->{lowercase} ){
                @words = map( lc($_), @words );
        }
	my $stopwords = getStopWords('en');
	@words = grep { !$stopwords->{$_} } @words;
	stem_in_place(@words);
        return @words;
}

1;
