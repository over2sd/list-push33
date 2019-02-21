#!/usr/bin/perl
use warnings;
use strict;
my $PROGRAMNAME = "Intro";
my $version = "0.01a";
my $cfn = "config.ini";
my $debug = 0;
#my $debug = 9;
my $dbn = 'dj45.dbl';
my $dbs = '';

$|++; # Immediate STDOUT, maybe?
print "[I] $PROGRAMNAME v$version is running.";
flush STDOUT;

use Getopt::Long;

GetOptions(
	'data|d=s' => \$dbn,
	'host|h=s' => \$dbs,
	'conf|c=s' => \$cfn,
	'verbose|v' => \$debug,
);

sub howVerbose {
	return $debug;
}

use lib "./modules/";
print "\n[I] Loading modules...";

require Sui;
require Common;
require FIO;
FIO::loadConf($cfn);
FIO::config('Debug','v',$debug);
FIO::config('Debug','termcolors',1);
require NoGUI;
my $text = StatusBar->new();
require FlexSQL;
print "\n";


Common::errorOut('inline',0,string => "[I] Checking for database...");
my ($dbh,$error) = FlexSQL::getDB('L') or undef;
print "\tOK\n" unless $error;
die $error if $error;
Sui::storeData('dbh',$dbh);
Common::errorOut('inline',0,string => "[I] Checking for tables...");
foreach my $t (qw( cddbmeta xmeta )) {
	my $good = FlexSQL::table_exists($dbh,$t);
	if ($good) {
		Common::errorOut('inline',0,string => "[I] Table $t found.");
	} else {
		Common::errorOut('inline',0,string => "[I] Table $t not found. Attempting to create...");
		FlexSQL::makeTables($dbh);
	}
}
Common::errorOut('inline',0,string => "[I] Checking for data files...");
print "\tdata.msq...";
if (-s "data.msq") {
	print "found; reading...";
	FlexSQL::makeTables($dbh,$text,"data");
}


$text->push("Ready.");

my $st = "SELECT * FROM cddbmeta LIMIT 10;";

my ($res,$err,$val) = FlexSQL::doQuery(3,$dbh,$st,'trackid');
use Data::Dumper;
print Dumper $res;
FlexSQL::closeDB($dbh);
print "Exiting normally\n";

1;