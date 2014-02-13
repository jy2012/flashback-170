#!/usr/bin/env perl

use strict;
use warnings;

use DBI;
use CGI;

my $cgi = CGI->new;

my $email = $cgi->param('email');
my $old_password = $cgi->param('old_password');
my $new_password = $cgi->param('new_password');

my $db_location = "./db/fb.sqlite";

print STDERR " calling process-change-password.pl";

my $dbh = DBI->connect("dbi:SQLite:dbname=".$db_location, 
                        undef, 
                        undef, 
                        { sqlite_unicode => 1});

my $statement = $dbh->prepare("SELECT * FROM users WHERE password = ?");
$statement->execute(($old_password));

my @results = $statement->fetchrow_array;

if ((scalar @results) == 0) {
    print  $cgi->redirect('./change-pass-error.html');    
}
else {
    $statement = $dbh->prepare("UPDATE users
                                    SET password = ?
                                    WHERE password = ?");
    $statement->execute(($new_password, $old_password));

    print $cgi->redirect('./your-settings.html');    
}
