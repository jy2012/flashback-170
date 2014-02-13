#!/usr/bin/env perl

# Currently doesn't work

use strict;
use warnings;

use DBI;
use CGI;

my $cgi = CGI->new;

my $name = $cgi->param('name');
my $birthday = $cgi->param('birthday');
my $email = $cgi->param('email');
my $password = $cgi->param('password');

my $db_location = "./db/fb.sqlite";

my $dbh = DBI->connect("dbi:SQLite:dbname=".$db_location, 
                        undef, 
                        undef, 
                        { sqlite_unicode => 1});

my $statement = $dbh->prepare("INSERT INTO users (email, password, name, birthday)  
                                VALUES (?, ?, ?, ?)");

$statement->execute(($email, $password, $name, $birthday)) or die $statement->errstr;


$statement = $dbh->prepare("SELECT rowid 
                                FROM users 
                                WHERE email = ? AND password = ?");
$statement->execute(($email,$password));

my @results = $statement->fetchrow_array;
my $userid = $results[0];
print STDERR $userid . "\n";
my $cookie = $cgi->cookie(-name=>'user_id',-value=>$userid);

my $upload_dir = "./users/user$userid";
mkdir $upload_dir unless -d $upload_dir;
$upload_dir .= "/photos";
mkdir $upload_dir unless -d $upload_dir;

foreach my $age_range (("youth", "20s", "30s", "40s", "50s", "60s", "70s", "80s")) {
    mkdir $upload_dir."/$age_range" unless -d $upload_dir."/$age_range";
}


print  $cgi->redirect(-uri => './your-brain.html', -cookie=>$cookie);    
