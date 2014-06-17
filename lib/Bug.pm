package Bugzilla::Extension::DupFinder::Bug;

use strict;

use Bugzilla::Util qw(detaint_natural);
use List::MoreUtils qw(firstidx uniq part);
use Bugzilla::Extension::DupFinder::DocumentCollection;
use Bugzilla::Extension::DupFinder::Document;

use constant MAX_POSSIBLE_DUPLICATES => 10;

sub possible_duplicates {
    my ($self, $params) = @_;
    my $short_desc = $params->{summary};
    my $desc = $params->{description};
    my $products = $params->{products} || [];
    my $limit = $params->{limit} || MAX_POSSIBLE_DUPLICATES;
    $limit = MAX_POSSIBLE_DUPLICATES if $limit > MAX_POSSIBLE_DUPLICATES;
    $products = [$products] if !ref($products) eq 'ARRAY';

    my $orig_limit = $limit;
    detaint_natural($limit) 
        || ThrowCodeError('param_must_be_numeric', 
                          { function => 'possible_duplicates',
                            param    => $orig_limit });

    my $dbh = Bugzilla->dbh;
    my $user = Bugzilla->user;
    my $sql_limit = 100;
    my $possible_dupes = $dbh->selectall_arrayref(
        "SELECT bugs.bug_id AS bug_id, bugs.short_desc AS summary, 
		descriptions.thetext AS description
	 FROM bugs  INNER JOIN 
	(SELECT * FROM bugs.longdescs ld1 WHERE bug_when = 
	(SELECT MIN(bug_when) FROM bugs.longdescs ld2 WHERE ld1.bug_id = ld2.bug_id))
	descriptions ON bugs.bug_id = descriptions.bug_id ORDER BY creation_ts DESC " .
          $dbh->sql_limit($sql_limit), {Slice=>{}});
    
    my $docs = Bugzilla::Extension::DupFinder::DocumentCollection->new( file => 'coll.db' );

    foreach my $bug (@$possible_dupes) {
        my $id = $bug->{bug_id};
	my $summary = $bug->{summary};
	my $description = $bug->{description};
        my $doc = Bugzilla::Extension::DupFinder::Document->new();
	$doc->AddContent($summary." ".$description);
	$docs->Add($id, $doc);
    }

    my $newdoc = Bugzilla::Extension::DupFinder::Document->new();
    $newdoc->AddContent($short_desc." ".$desc);
    my @result = $docs->EnumerateV( \&Bugzilla::Extension::DupFinder::Bug::computeSimilarity, $newdoc);

    my @new_result = sort {$b->[1] cmp $a->[1]} @result;
    my @actual_dupe_ids;

    foreach my $bug (@new_result) {
        if ($bug->[1] > 0){
            my $push_id = $bug->[0];
            push(@actual_dupe_ids, $push_id);
        }
    }

    @actual_dupe_ids = uniq @actual_dupe_ids;
    if (scalar @actual_dupe_ids > $limit) {
        @actual_dupe_ids = @actual_dupe_ids[0..($limit-1)];
    }

    my $visible = $user->visible_bugs(\@actual_dupe_ids);
    return Bugzilla::Bug->new_from_list($visible);
}

sub computeSimilarity {
    my $self = shift;
    my ($key,$doc,$newdoc) = @_;
    my $simScore = $doc->WeightedCosineSimilarity( $newdoc, \&Bugzilla::Extension::DupFinder::DocumentCollection::IDF, $self );
    my @result = [$key, $simScore];
    return @result;
}

1;

