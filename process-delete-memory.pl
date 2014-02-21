#!/usr/bin/env perl

# Currently doesn't work

use strict;
use warnings;

use Template;
use DBI;
use CGI;
use Digest::MD5 qw(md5);

my $db_location = "./db/fb.sqlite";

my $dbh = DBI->connect("dbi:SQLite:dbname=".$db_location, 
                        undef, 
                        undef, 
                        { sqlite_unicode => 1});

my $cgi = CGI->new;
my $userid = $cgi->cookie('user_id');

my $memory_name = $cgi->param('memory_name');
my $age_range = $cgi->param('age_range');
my $image_url = $cgi->param('image_url');
my $query = $cgi->param('query');

print STDERR "$memory_name $age_range $image_url\n";

my $statement = $dbh->prepare("DELETE FROM memories 
                                WHERE user_id = ? AND memory_name = ? AND age_range = ? AND image_url = ?;");

$statement->execute(($userid, $memory_name, $age_range, $image_url)) or die $statement->errstr;

my $tt = Template->new({
        INCLUDE_PATH => './templates',
        INTERPOLATE => 1,
}) or die($!);


#print $cgi->redirect('./your-'.$age_range.'.pl');    

if ($query eq "") {
    print $cgi->header;
    $tt->process('message.html', 
                    { message => "Memory deleted!",
                      callback_link => "./age-range.pl?age_range=$age_range",
                      callback_message => "Back" }) 
    or die($!);
}
else {
    print $cgi->header;
    $tt->process('message.html', 
                    { message => "Memory deleted!",
                      callback_link => "./process-search.pl?query=$query",
                      callback_message => "Back" }) 
    or die($!);
}
