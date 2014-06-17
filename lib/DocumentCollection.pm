package Bugzilla::Extension::DupFinder::DocumentCollection;
#This is basically a source code of Text::DocumentCollection, but with no DB
use strict;
use warnings;

sub new
{
        my $class = shift;
        my %self = @_;
        my $self = \%self;
        bless $self, $class;
        return $self;
}
 
sub Add
{
        my $self = shift;
        my ($key,$doc) = @_;
 
        if( defined( $self->{docs}->{$key} ) ){
                die( __PACKAGE__ . '::Add : '
                        . "document `$key' is already in this collection"
                );
        }
 
        $self->{docs}->{$key} = $doc;
 
        delete $self->{IDF};
  
        return $doc;
}
 
sub Delete
{
        my $self = shift;
        my ($key) = @_;
 
        if( not defined( $self->{docs}->{$key} ) ){
                return undef;
        }
        delete $self->{docs}->{$key};
        return 1;
}
 
sub EnumerateV
{
        my $self = shift;
        my ($callback,$rock) = @_;
 
        my @result = ();
        while( my @kv = each %{$self->{docs}} ){
                my @l = &{$callback}( $self, $kv[0], $kv[1], $rock );
                push @result, @l;
        }
        return @result;
}
 
sub IDF_Help
{
        my $self = shift;
        my ($key,$doc,$term) = @_;
 
        my $o = $doc->Occurrences( $term );
        $self->{_idf_n}++;
        if( $o and ($o>0) ){
                $self->{_idf_dt}++;
        }
}
 
sub IDF
{
        my $self = shift;
        my ($term) = @_;
 
        defined( $self->{IDF}->{$term} ) and return $self->{IDF}->{$term};
        $self->{_idf_n} = 0;
        $self->{_idf_dt} = 0;
        $self->EnumerateV( \&Bugzilla::Extension::DupFinder::DocumentCollection::IDF_Help, $term );
        if( $self->{_idf_dt} <= 0 ){
                warn( "term $term does not occur in any document" );
                return $self->{IDF}->{$term} = 0.0;
        }
        $self->{IDF}->{$term} =
                log( $self->{_idf_n} / $self->{_idf_dt} ) / log(2.0);

        return $self->{IDF}->{$term} ;
}
 
1;
