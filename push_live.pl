#!/usr/bin/env perl

use strict;
use warnings;

use Digest::MD5 q(md5_hex);

system("tar -zcvf ../fb_backups/fb_test_backup_". md5_hex(localtime) .".tar ../../public/fb_test/");
system("cp -vR . ../../public/fb_test");
system("rm ../../public/fb_test/push_live.pl");
