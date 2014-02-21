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
my $image_name = $cgi->param('image_name'); 
my $age_range = $cgi->param('age_range'); 
my $query = $cgi->param('query') // "";


my $statement = $dbh->prepare("SELECT image_url FROM memories WHERE 
                                user_id = ? AND memory_name = ? AND age_range = ?"); 

$statement->execute(($user_id, $image_name, $age_range)) or die $statement->errstr;

my @result = $statement->fetchrow_array;

my $url = $result[0];

=comment
my @imageURLs;

opendir(my $photo_dir, $directory) or die($!);
while (my $file = readdir($photo_dir)) {
    if (!($file =~ m/^\./)) {
        push @imageURLs, "$directory/$file";
    }
}
=cut

print $cgi->header;
$tt->process('edit-memory.html', 
                { memory_name => $image_name, image_url => $url , age_range => $age_range, 
                    query => $query } )
    or die($!);
