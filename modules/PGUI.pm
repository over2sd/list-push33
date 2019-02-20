package PGUI;
print __PACKAGE__;
use strict; use warnings;

require Exporter;
our @ISA = qw(Exporter);
our @EXPORT_OK = qw( );

use FIO qw( config );
use PGK qw( labeledRow sayBox labelBox );
use Prima qw( ImageViewer Sliders Calendar Edit );
use Common qw( missing infMes );
use Options;
=head1 NAME

PGUI - A module for Prima GUI elements

=head2 DESCRIPTION

A library of functions used to build and manipulate the program's Prima user interface elements.

=head3 Functions

=cut

=item carpWithout PREQ ACTIONTEXT PREQTEXT using a sayBox

IF PREQ is undefined, complain that ACTIONTEXT can't be done without PREQTEXT
Returns 0 if PREQ is defined.
Returns 1 if message was triggered.

=cut

# 	carpWithout($ifn,$process,"specify an input filename") and return;
sub carpWithout {
	my ($preq,$action,$preqtxt) = @_;
	defined $preq and return 0;
	sayBox(getGUI('mainWin'),"You can't $action until you $preqtxt!");
	return 1;
}
print ".";

sub showapic {
	my ($lfp,$img,$viewsize) = @_;
	my $pic = Prima::Image->new;
	my $lfn = "$lfp$img";
	$pic->load($lfn) or die "Could not load $lfn!";
#	$pic->set(scaling => 7); # ist::Hermite);
	my $iz = 1;
	if ($pic->width > $pic->height) {
		my $w = $pic->width;
		$iz = $viewsize / $pic->width; # get appropriate scale
		$pic->size($pic->height * $iz,$viewsize); # resize the image to fit our viewport
	} else {
		my $h = $pic->height;
		my $iz = $viewsize / $pic->height; # get appropriate scale
		$pic->size($viewsize,$pic->width * $iz); # resize the image to fit our viewport
	}
	return ($pic,$iz);
}
print ".";

require FSPider;

package PGUI;


sub resetPencil {
	my ($args) = @_;
	my $sequence = [];
	my $target = $$args[0]; # unpack from dispatcher sending ARRAYREF
	my $bgcol = $$args[1];
	$target->empty(); # start with a blank slate
	my $fco = $$args[2];
	my $bh = 45;
	my $bw = (FIO::config('UI','sliderwidth') or 350);
	my $tf = 1.9;
	my $lw = 75;
	my $picsize = (FIO::config('UI','graphsize') or 200);

	$target->insert( Label => text => "PENCIL Configuration" );
	my $pbox = $target->insert( HBox => name => "Pencil holder", pack => { fill => 'both', expand => 0 }, );
	my ($graph,$zoom) = (Prima::Image->create(width => $picsize, height => $picsize), 1);
	my $imagebox = $pbox->insert( HBox => width => $picsize + 13, height => $picsize + 13);
	my $vp = $imagebox->insert( ImageViewer =>
		name => "img", zoom => $zoom, width => $picsize, height => $picsize,
		pack => {fill => 'none', expand => 1 }, image => $graph); $::application->yield();
	my $pcase = $pbox->insert( VBox => name => "Pencil case", pack => { fill => 'y', expand => 0, } );
	my %props = ( pack => { fill => 'x', expand => 0 }, min => 0, max => 9, shaftBreadth => 5, width => $bw, height => $bh, ticks => [{value => 0, height => 3, text => '0'},{value => 4, height => 3, text => '4'},{value => 9,height => 3,text => '9'}] );
	
	my $pc = $pcase->insert( HBox => name => "p", alignment => ta::Left );
	$pc->pack( fill => 'x', expand => 0, padx => 3, pady => 1, );
	$pc->insert( Label => text => "Anxiety", width => $lw );
	my $pcp = $pc->insert( Slider => name => "peace", %props );
	$pc->insert( Label => text => "Peace", width => $lw );
	$fco->pencil(0,$pcp);
	$pcp->onChange(sub { $fco->pencil(0,$pcp); });

	my $ec = $pcase->insert( HBox => name => "e", alignment => ta::Left );
	$ec->pack( fill => 'x', expand => 0, padx => 3, pady => 1, );
	$ec->insert( Label => text => "Sad", width => $lw );
	my $pce = $ec->insert( Slider => name => "emotional color", %props );
	$ec->insert( Label => text => "Happy", width => $lw );
	$fco->pencil(1,$pce);
	$pce->onChange(sub { $fco->pencil(1,$pce); });

	my $nc = $pcase->insert( HBox => name => "n", alignment => ta::Left );
	$nc->pack( fill => 'x', expand => 0, padx => 3, pady => 1, );
	$nc->insert( Label => text => "Few", width => $lw );
	my $pcn = $nc->insert( Slider => name => "notes per minute", %props );
	$nc->insert( Label => text => "Many", width => $lw );
	$fco->pencil(2,$pcn);
	$pcn->onChange(sub { $fco->pencil(2,$pcn); });

	my $cc = $pcase->insert( HBox => name => "c", alignment => ta::Left );
	$cc->pack( fill => 'x', expand => 0, padx => 3, pady => 1, );
	$cc->insert( Label => text => "Simple", width => $lw );
	my $pcc = $cc->insert( Slider => name => "complexity", %props );
	$cc->insert( Label => text => "Profound", width => $lw );
	$fco->pencil(3,$pcc);
	$pcc->onChange(sub { $fco->pencil(3,$pcc); });

	my $ic = $pcase->insert( HBox => name => "i", alignment => ta::Left );
	$ic->pack( fill => 'x', expand => 0, padx => 3, pady => 1, );
	$ic->insert( Label => text => "Smooth", width => $lw );
	my $pci = $ic->insert( Slider => name => "intensity", %props );
	$ic->insert( Label => text => "Driving", width => $lw );
	$fco->pencil(4,$pci);
	$pci->onChange(sub { $fco->pencil(4,$pci); });

	my $lc = $pcase->insert( HBox => name => "l", alignment => ta::Left );
	$lc->pack( fill => 'x', expand => 0, padx => 3, pady => 1, );
	$lc->insert( Label => text => "All Instruments", width => $lw );
	my $pcl = $lc->insert( Slider => name => "logorism", %props );
	$lc->insert( Label => text => "All Words", width => $lw );
	$fco->pencil(5,$pcl);
	$pcl->onChange(sub { $fco->pencil(5,$pcl); });

	my $textbox = $target->insert( Edit => text => ";", name => "SQL command window", width => $bw * $tf, height => $bh * $tf * 2 );
	my $commander = $target->insert( HBox => name => "SQL buttons" );
	my $genbut = $commander->insert( Button => text => "Generate", onClick => sub {
		$textbox->text($fco->insertQuery());
		} );
	my $exebut = $commander->insert( Button => text => "Execute");
	
}

=item populateMainWin DBH GUI REFRESH

Given a DBHandle, a GUIset, and a value indicating whether or not to REFRESH the window, generates the objects that fill the main window.
At this time, DBH may be undef.
Returns 0 on successful completion.

=cut

sub populateMainWin {
	my ($dbh,$gui,$refresh) = @_;
	($refresh && (defined $$gui{pager}) && $$gui{pager}->destroy());
	my $win = $$gui{mainWin};
	my $stat = $$gui{status};
	my $fio = FSPider::getUnpenciled();
	my $fn = %$fio->{path};
	$fn = "$fn" . %$fio->{file};
	my $player = FSPider::buildPlayer($win,$dbh,$fn,$stat); # returns filecontrol object
	my @tabs = qw( PENCIL Data Rating Stats );
	my $pager = $win->insert( Pager => name => 'Pages', pack => { fill => 'both', expand => 1}, );
	$pager->build(@tabs);
	my $i = 1;
	my $color = Common::getColors(13,1,1);
	my $currpage = 0; # placeholder

	# Pencil tab
	my $hexpage = $pager->insert_to_page($currpage++,VBox =>
		backColor => PGK::convertColor($color),
		pack => { fill => 'both', },
	);
	$pager->setSwitchAction("PENCIL",\&resetPencil,$hexpage,$color,$player);

	# Data tab
	$color = Common::getColors(6,1,1);
	my $datpage = $pager->insert_to_page($currpage++,VBox =>
		backColor => ColorRow::stringToColor($color),
		pack => { fill => 'both', },
	);
	my $gp = labelBox($datpage,"Data page not yet coded.",'g','H', boxfill => 'both', boxex => 1, labfill => 'x', labex => 1);
#	$pager->setSwitchAction("Data",\&resetData,$datpage,$color);

	# Rating tab
	$color = Common::getColors(10,1,1);
	my $ratepage = $pager->insert_to_page($currpage++,VBox =>
		backColor => ColorRow::stringToColor($color),
		pack => { fill => 'both', },
	);
	my $op = labelBox($ratepage,"Rating page not yet coded.",'o','H', boxfill => 'y', boxex => 1, labfill => 'x', labex => 1);
	$op->set(backColor => PGK::convertColor($color));
#	$pager->setSwitchAction("Rating",\&resetRating,$ratepage,$color); # refresh this page whenever we switch to it

	# Stats tab
	$color = Common::getColors(7,1,1);
	my $statpage = $pager->insert_to_page($currpage++,VBox =>
		backColor => ColorRow::stringToColor($color),
		pack => { fill => 'both', },
	);
#	$pager->setSwitchAction("Stats",\&resetStats,$statpage,$color); # refresh this page whenever we switch to it
	my $sp = labelBox($statpage,"Stats page not yet coded.",'r','H', boxfill => 'x', boxex => 1, labfill => 'x', labex => 1);
	$sp->set(backColor => PGK::convertColor($color));
	$color = Common::getColors(($i++ % 2 ? 0 : 7),1);

	$pager->switchToPanel("PENCIL");
	$$gui{pager} = $pager;
	return 0;
}
print ".";

=item buildMenus GUI

Given a GUIset, generates the menus this program will show on its menubar.
Returns a reference to the menu array that Prima can use to build the menubar. 

=cut

sub buildMenus { #Replaces Gtk2::Menu, Gtk2::MenuBar, Gtk2::MenuItem
	my $gui = shift;
	my $menus = [
		[ '~File' => [
			['~Preferences', sub { return callOptBox($gui); }],
			[],
			['Close', 'Ctrl-W', km::Ctrl | ord('W'), sub { $$gui{mainWin}->close() } ],
		]],
		[ '~Help' => [
			['~About',sub { \&aboutBox, $$gui{mainWin} }],
		]],
	];
	return $menus;
}
print ".";

=item aboutBox TARGET

Given a TARGET parent window, displays information about the program.
Returns the return value of sayBox().

=cut

sub aboutBox {
	my $target = shift;
	return sayBox($target,Sui::aboutMeText());
}

=item callOptBox [GUI]

Given a GUIset, generates an options dialog.
Returns the return value of the option box function.

=cut

sub callOptBox {
	my $gui = shift || getGUI();
	my %options = Sui::passData('opts');
	return Options::mkOptBox($gui,%options);
}
print ".";

=item devHelp PARENT UNFINISHEDTASK

Displays a message that UNFINISHEDTASK is not done but is planned.
TODO: Remove from release.
No return value.

=cut
sub devHelp {
	my ($target,$task) = @_;
	sayBox($target,"$task is on the developer's TODO list.\nIf you'd like to help, check out the project's GitHub repo at http://github.com/over2sd/list-push33.");
}
print ".";


print " OK; ";
1;
