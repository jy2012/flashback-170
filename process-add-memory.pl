#!/usr/bin/env perl

# Currently doesn't work

use strict;
use warnings;

use Template;
use DBI;
use CGI;
use Digest::MD5 qw(md5 md5_hex);

my $db_location = "./db/fb.sqlite";

my $dbh = DBI->connect("dbi:SQLite:dbname=".$db_location, 
                        undef, 
                        undef, 
                        { sqlite_unicode => 1});

my $cgi = CGI->new;
my $userid = $cgi->cookie('user_id');

my $memory_name = $cgi->param('memory_name');
my $filename = $cgi->param('photo');
my $age_range = $cgi->param('age_range');

my $upload_dir = "./users/user$userid";
mkdir $upload_dir unless -d $upload_dir;
$upload_dir .= "/photos";
mkdir $upload_dir unless -d $upload_dir;
$upload_dir .= "/$age_range";
mkdir $upload_dir unless -d $upload_dir;

my $upload_filehandle = $cgi->upload('photo');

my ($ext) = $filename =~ /(\.[^.]+)$/;
$filename = md5_hex(localtime) . $ext; 

if (defined $upload_filehandle) {
    open (my $up_out, ">$upload_dir/$filename") or die($!);
    binmode $up_out;

    while (<$upload_filehandle>) {
        print $up_out $_;
    }
    close $up_out;
}

my $tt = Template->new({
        INCLUDE_PATH => './templates',
        INTERPOLATE => 1,
}) or die($!);


if ($memory_name eq "") {
    print $cgi->header;
    $tt->process('message.html', 
                    { message => "No memory name specified.",
                      callback_link => "./age-range.pl?age_range=$age_range",
                      callback_message => "Try again?" }) 
}

else {
    my $statement = $dbh->prepare("INSERT INTO memories (user_id, memory_name, image_url, age_range)  
                                    VALUES (?, ?, ?, ?)");

    $statement->execute(($userid, $memory_name, "$upload_dir/$filename", $age_range)) or die $statement->errstr;


    print $cgi->header;
    $tt->process('message.html', 
                    { message => "Memory added!",
                      callback_link => "./age-range.pl?age_range=$age_range",
                      callback_message => "Back to $age_range" }) 
    or die($!);
}
