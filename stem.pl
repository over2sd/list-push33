#!/usr/bin/perl
use warnings;
use strict;
my $PROGRAMNAME = "Stem";
my $version = "0.01a";
my $cfn = "config.ini";
my $debug = 9;
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
require FlexSQL;
require PGK;
require FSPider;
require PGUI;
FIO::loadConf($cfn);
FIO::config('Debug','v',$debug);

use Prima qw(Application Buttons MsgBox FrameSet Edit );
my $gui = PGK::createMainWin($PROGRAMNAME,$version,800,570);
my $text = $$gui{status};
#PGK::startwithDB($gui,$PROGRAMNAME,0);

my $dbh = FlexSQL::getDB('L') or undef;
Sui::storeData('dbh',$dbh);
print "$dbh - " . ref($dbh) . "\n";
PGUI::populateMainWin($dbh,$gui,0);

sub beforeClosing {
	FSPider::closeSound();

}

$text->push("Ready.");
Options::formatTooltips();
print "\n";
Prima->run();
print "Exiting normally\n";
1;