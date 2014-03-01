#!/usr/bin/env perl

# Currently doesn't work

use strict;
use warnings;

use Template;
use DBI;
use CGI;
use Time::Local;

sub thisyear {
    my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) =
                                                    localtime(time);
    return 1900+$year;
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

my $name = $cgi->param('name');
my $birthday = $cgi->param('birthday');
my $email = $cgi->param('email');
my $password = $cgi->param('password');
my $confirm_password = $cgi->param('confirm_password');

my $db_location = "./db/fb.sqlite";

my $dbh = DBI->connect("dbi:SQLite:dbname=".$db_location, 
                        undef, 
                        undef, 
                        { sqlite_unicode => 1});

my $tt = Template->new({
        INCLUDE_PATH => './templates',
        INTERPOLATE => 1,
}) or die($!);

if ($password ne $confirm_password) {
    print $cgi->header;
    $tt->process('message.html', 
                    { message => "Passwords don't match.",
                      callback_link => "./sign-up.html",
                      callback_message => "Try again?" }) 
    or die($!);
}

elsif ($name eq "") {
    print $cgi->header;
    $tt->process('message.html', 
                    { message => "No name given.",
                      callback_link => "./sign-up.html",
                      callback_message => "Try again?" }) 
    or die($!);
}

elsif (!($birthday =~ m/^\d{1,2}\/\d{1,2}\/\d{4}$/)) {
    print $cgi->header;
    $tt->process('message.html', 
                    { message => "Invalid format for birthday.",
                      callback_link => "./sign-up.html",
                      callback_message => "Try again?" }) 
    or die($!);
}

elsif (check_birthday($birthday) == 0) {
    print $cgi->header;
    $tt->process('message.html', 
                    { message => "Invalid birthday.",
                      callback_link => "./sign-up.html",
                      callback_message => "Try again?" }) 
    or die($!);
}

elsif ($email eq "") {
    print $cgi->header;
    $tt->process('message.html', 
                    { message => "No email given.",
                      callback_link => "./sign-up.html",
                      callback_message => "Try again?" }) 
    or die($!);
}

elsif ($password eq "") {
    print $cgi->header;
    $tt->process('message.html', 
                    { message => "No password given.",
                      callback_link => "./sign-up.html",
                      callback_message => "Try again?" }) 
    or die($!);
}

else {
    my $statement = $dbh->prepare("SELECT rowid 
                                    FROM users 
                                    WHERE email = ? ");
    $statement->execute(($email));
    my @results = $statement->fetchrow_array;
    if ((scalar @results) > 0) {
        print $cgi->header;
        $tt->process('message.html', 
                        { message => "E-mail is already in our database.",
                          callback_link => "./sign-up.html",
                          callback_message => "Try again?" }) 
        or die($!);
    }

    else {
        $statement = $dbh->prepare("INSERT INTO users (email, password, name, birthday)  
                                        VALUES (?, ?, ?, ?)");

        $statement->execute(($email, $password, $name, $birthday)) or die $statement->errstr;


        $statement = $dbh->prepare("SELECT rowid 
                                        FROM users 
                                        WHERE email = ? AND password = ?");
        $statement->execute(($email,$password));

        @results = $statement->fetchrow_array;
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
    }
}
