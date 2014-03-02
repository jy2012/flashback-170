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

my $userid = $cgi->cookie('user_id');
my $age_range = $cgi->param('age_range');

my $tt = Template->new({
        INCLUDE_PATH => './templates',
        INTERPOLATE => 1,
}) or die($!);

print $cgi->header;
$tt->process('add-memory.html', 
                { user_id => $userid,
                  age_range => $age_range
                  }) 
    or die($!);
