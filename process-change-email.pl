#!/usr/bin/env perl

use strict;
use warnings;

use DBI;
use CGI;

my $cgi = CGI->new;

my $old_email = $cgi->param('old_email');
my $new_email = $cgi->param('new_email');

my $db_location = "./db/fb.sqlite";

print STDERR "calling process-change-email.pl\n";

my $dbh = DBI->connect("dbi:SQLite:dbname=".$db_location, 
                        undef, 
                        undef, 
                        { sqlite_unicode => 1});

my $statement = $dbh->prepare("UPDATE users
                                SET email = ?
                                WHERE email = ?");
$statement->execute(($new_email, $old_email));

print $cgi->redirect('./your-settings.html');    
