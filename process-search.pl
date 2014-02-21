#!/usr/bin/env perl

use strict;
use warnings;

use Template;
use CGI;
use DBI;

my $db_location = "./db/fb.sqlite";

my $dbh = DBI->connect("dbi:SQLite:dbname=".$db_location, 
                        undef, 
                        undef, 
                        { sqlite_unicode => 1});

my $cgi = CGI->new;

my $tt = Template->new({
        INCLUDE_PATH => './templates',
        INTERPOLATE => 1,
}) or die($!);

my $user_id = $cgi->cookie('user_id');
my $query = $cgi->param('query');

my $statement = $dbh->prepare("SELECT memory_name, image_url, age_range FROM memories
                                 WHERE user_id = ? AND memory_name LIKE ?");

$statement->execute(($user_id, "%$query%")) or die $statement->errstr;

my @images;

my @data;
while (@data = $statement->fetchrow_array) {
    push @images, { name => $data[0], url => $data[1], age_range => $data[2] };
}

=comment
opendir(my $photo_dir, $directory) or die($!);
while (my $file = readdir($photo_dir)) {
    if (!($file =~ m/^\./)) {
        push @imageURLs, "$directory/$file";
    }
}
=cut

print $cgi->header;
$tt->process('search-results.html', 
                {   query => $query, 
                    user_id => $user_id,
                    images => \@images }) 
    or die($!);
