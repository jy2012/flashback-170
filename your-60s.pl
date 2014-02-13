#!/usr/bin/env perl

use strict;
use warnings;

use Template;
use CGI;

my $cgi = CGI->new;
my $tt = Template->new({
        INCLUDE_PATH => './templates',
        INTERPOLATE => 1,
}) or die($!);

my $user_id = $cgi->cookie('user_id');

my $directory = "./users/user$user_id/photos/60s";

my @imageURLs;

opendir(my $photo_dir, $directory) or die($!);
while (my $file = readdir($photo_dir)) {
    if (!($file =~ m/^\./)) {
        push @imageURLs, "$directory/$file";
    }
}

print $cgi->header;
$tt->process('your-60s.html', 
                { user_id => $user_id,
                  imageURLs => \@imageURLs }) 
    or die($!);
