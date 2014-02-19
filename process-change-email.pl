#!/usr/bin/env perl

use strict;
use warnings;

use Template;
use DBI;
use CGI;

my $cgi = CGI->new;

my $new_email = $cgi->param('email');
my $confirm_new_email = $cgi->param('confirm_email');
my $userid = $cgi->cookie('user_id');

my $db_location = "./db/fb.sqlite";

print STDERR "calling process-change-email.pl\n";

my $dbh = DBI->connect("dbi:SQLite:dbname=".$db_location, 
                        undef, 
                        undef, 
                        { sqlite_unicode => 1});

my $tt = Template->new({
        INCLUDE_PATH => './templates',
        INTERPOLATE => 1,
}) or die($!);

if ($new_email ne $confirm_new_email) {
    print $cgi->header;
    $tt->process('message.html', 
                    { message => "Emails don't match.",
                      callback_link => "./change-e-mail.html",
                      callback_message => "Try again?" }) 
    or die($!);
}

else {
    my $statement = $dbh->prepare("UPDATE users
                                    SET email = ?
                                    WHERE rowid = ?");
    $statement->execute(($new_email, $userid));

    print $cgi->header;
    $tt->process('message.html', 
                    { message => "Email changed (" . $new_email . ")",
                      callback_link => "./your-settings.html",
                      callback_message => "Back to Settings" }) 
    or die($!);
}
