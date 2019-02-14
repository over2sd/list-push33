package FSPider;
print __PACKAGE__;
=head2 FSPider

File/SQL/Prima interface (like a spider with its arms in many place). Contains information about a file, its SQL storage, and its Prima objects.

=head3 Usage

  my $file = FSPider->new(fn => "foo.mp3", title => "Foo on the Bar", sqlid => "b33f", playerparent => $vbox );

=cut

use Win32::API;

use vars qw($mci $retstring $stop);
#- Import mciSendStringA
$mci = new Win32::API("winmm", "mciSendStringA", 'PPNN', 'N')
    or die "No we have no bananas....";
#- Init $retstring
$retstring=" "x256;

sub new {
	my ($class,%profile) = @_;
	my $self = {
		fn => ($profile{fn} or "missing.wav"),
		title => ($profile{title} or "Description Missing"),
		sqlquery => "INSERT INTO xmeta(trackid,p,e,n,c,i,l) VALUES (%s);",
		sqlid => ($profile{sqlid} or "0"),
		playb => ($profile{playbutton} or undef),
		psl => ($profile{pslider} or undef),
		esl => ($profile{eslider} or undef),
		nsl => ($profile{nslider} or undef),
		csl => ($profile{cslider} or undef),
		isl => ($profile{islider} or undef),
		lsl => ($profile{lslider} or undef),
		slpar => ($profile{sliderparent} or undef),
		plpar => ($profile{playerparent} or undef),
	};
	bless $self, $class;
	return $self;
}
print ".";

sub get {
	my ($self,$key) = @_;
	defined $key or return undef;
	return $self->{$key};
}

sub set {
	my ($self,$key,$value) = @_;
	defined $value and defined $key or return undef;
	$self->{$key} = $value;
	return $self->{$key};
}

sub pencil {
	my ($self,$attr,$val) = @_;
	my @keys = qw( psl esl nsl csl isl lsl );
	unless (defined $val) {
		return $self->{$keys[$attr]};
	}
	unless (defined $attr) {
		my @pa = ();
		foreach my $i (0..5) {
			push(@pa,$self->{$keys[$i]});
		}
		return @pa;
	}
	$self->{$keys[$attr]} = $val;
	return $val;
}

sub insertQuery {
	my ($self) = @_;
	my $query = $self->{sqlquery};
	my $attrs = $self->{sqlid};
	foreach my $i (0..5) {
		my $v = $self->pencil($i)->value;
		$attrs = "$attrs,$v";
	}
print "....$attrs....";
	return sprintf($query,$attrs);
}

sub loadFile {
	#- Open mp3 file
	my ($self,$filename) = @_;
	if (defined $filename) {
		$self->set("fn",$filename);
		if (defined $self->{playb} ) { # prevent multiple play buttons
			$self->{playb}->destroy();
		}
	} else {
		$filename = $self->get("fn");
	}
	$mci->Call("open $filename alias mysound",$retstring,256,0);
	my $pbut = $self->{plpar}->insert( Button => text => "[>", onClick => sub { #- Play it
		$mci->Call("play mysound",$retstring,256,0);
		} );
	$self->set("playb",$pbut);
#	$self->{sqlid} = Sui::getTrack($filename,0);
	$self->{sqlid} = getTrack("2001-Unknown-006.ogg",0);

	return 0;
}
print ".";

sub buildPlayer {
	my ($win,$dbh,$fn) = @_;
	my ($playerparent,) = PGK::labeledRow($win, "Controls: ", name => "Music Player", boxfill => 'x', boxex => 0, labfill => 'x', labex => 0 );
	my $pbutp = $playerparent->insert( HBox => name => "Play button parent" );
	my $fco = FSPider->new(fn => $fn, playerparent => $pbutp );
	$fco->loadFile($fn);
	my $stopbut = $playerparent->insert( Button => text => "||", onClick => sub { $mci->Call("pause mysound",$retstring,256,0); } );
	my $nextbut = $playerparent->insert( Button => text => ">|", onClick => sub { PGUI::devHelp($target, "Playing the next track"); } );
	return $fco;
}
print ".";

sub closeSound {
	#- Close
	$mci->Call("close mysound",$retstring,256,0);
}
print ".";

Common::registerErrors('FSPider::getTrack',"[E] Can't use database. Database not stored in Sui!: %s","[E] Can't get track without a filename to seek! %s");

sub getTrack {
	my ($fn,$field) = @_;
return; # until I can fix the DB module
	my $dbh = Sui::passData('dbh') or Common::errorOut("FSPider::getTrack",1, fatal => 0);
	Common::errorOut("FSPider::getTrack",2) unless defined $fn;
	if ($field == 0) {
		return FlexSQL::doQuery(0,$dbh,"SELECT trackid FROM cddbmeta WHERE file = ?;",$fn);
	}
	warn "\n[W] Unrecognized field passed to getTrack ($field)";
	return undef;
}
print ".";

print "OK";
1;