#!/usr/bin/env perl

use strict;
use warnings;

use Template;
use DBI;
use CGI;

my $cgi = CGI->new;

my $userid = $cgi->cookie('user_id');
my $old_password = $cgi->param('old_password');
my $new_password = $cgi->param('new_password');
my $confirm_new_password = $cgi->param('confirm_new_password');

my $db_location = "./db/fb.sqlite";

print STDERR " calling process-change-password.pl";

my $dbh = DBI->connect("dbi:SQLite:dbname=".$db_location, 
                        undef, 
                        undef, 
                        { sqlite_unicode => 1});

my $statement = $dbh->prepare("SELECT * FROM users WHERE password = ? AND rowid = ?");
$statement->execute(($old_password, $userid));

my @results = $statement->fetchrow_array;

my $tt = Template->new({
        INCLUDE_PATH => './templates',
        INTERPOLATE => 1,
}) or die($!);

if ((scalar @results) == 0) {
    print $cgi->header;

    $tt->process('message.html', 
                    { message => "Incorrect old password.",
                      callback_link => "./change-password.html",
                      callback_message => "Try again?" }) 
    or die($!);
}
elsif ($new_password ne $confirm_new_password) {
    print $cgi->header;
    $tt->process('message.html', 
                    { message => "New passwords don't match.",
                      callback_link => "./change-password.html",
                      callback_message => "Try again?" }) 
    or die($!);
}
else {
    $statement = $dbh->prepare("UPDATE users
                                    SET password = ?
                                    WHERE password = ? AND rowid = ?");
    $statement->execute(($new_password, $old_password, $userid));


    print $cgi->header;
    $tt->process('message.html', 
                    { message => "Password changed.",
                      callback_link => "./your-settings.html",
                      callback_message => "Back to Settings" }) 
    or die($!);
}
