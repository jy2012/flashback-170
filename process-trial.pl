#!/usr/bin/env perl

# Currently doesn't work

use strict;
use warnings;

use Template;
use DBI;
use CGI;
use Time::Local;
use Digest::MD5 qw(md5 md5_hex);

sub thisyear {
    my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) =
                                                    localtime(time);
    return 1900+$year;
}

sub today {
    my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) =
                                                    localtime(time);
    return "$mon/$mday/".thisyear();
}

sub check_birthday {
    my $birthday = shift;

    my ($month, $day, $year) =  split(m@/@, $birthday);

    my $retval = 0;
    eval {
        timelocal(0,0,0,$day, $month-1, $year);
        $retval = 1;
    };

    return $retval;
}

my $cgi = CGI->new;

my $name = "random person [" . $cgi->remote_host . "] (" . substr(md5_hex(localtime), -4) . ")";
my $birthday = today();
my $email = substr(md5_hex(localtime), -4) . "\@flashback.com";
my $password = substr(md5_hex(localtime), -4);

my $db_location = "./db/fb.sqlite";

my $dbh = DBI->connect("dbi:SQLite:dbname=".$db_location, 
                        undef, 
                        undef, 
                        { sqlite_unicode => 1});

my $tt = Template->new({
        INCLUDE_PATH => './templates',
        INTERPOLATE => 1,
}) or die($!);


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

#print  $cgi->redirect(-uri => './your-brain.html', -cookie=>$cookie);    
print $cgi->header(-cookie=>$cookie);
$tt->process('display-trial-login.html', 
                { email => $email,
                  password => $password 
                 }) 
or die($!);
