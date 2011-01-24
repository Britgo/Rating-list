#! /usr/bin/perl
#
# Update ratings list from last played file.
#
# Copyright John Collins 23/01/2011

use DBD::mysql;
use File::Copy;
use File::Compare;
use Time::Local;

sub Mysqldate_to_gmtime {
	my $mdate = shift;
	my ($yr,$mon,$day) = $mdate =~ /(\d{4})-(\d\d)-(\d\d)/;
	timegm(0,0,12,$day,$mon-1,$yr);
}

sub Tourn_date {
	my $tcode = shift;
	my ($yr,$mn,$dy) = $tcode =~ /.(..)(..)(..)/;
	if ($yr > 50) {
		$yr += 1900;
	}
	else {
		$yr += 2000;
	}
	sprintf "%.4d-%.2d-%.2d", $yr, $mn, $dy;
}

$EGD_source = "http://www.europeangodatabase.eu/EGD/EGD_2_0/downloads";
$EGD_file = "alleuro_lp.html";
$old_file = "alleuro_lp.html.save";
my $reliable_calibration_time = 60*60*24*35;

# This is the directory where we work in

$rating_scripts = "/var/www/ratings/scripts";

# Select that directory in case of any doubt

unless (chdir $rating_scripts)  {
	print STDERR "Could not open rating list directory\n";
	exit 9;
}

# If a copy of the file exists, then move it to the old file location so
# we don't have to bother if it's unchanged

if (-f $EGD_file)  {
	unlink $old_file;
	unless (copy($EGD_file, $old_file))  {
		print STDERR "Could not backup old file\n";
		exit 9;
	}
}
# Grab the rating file from EGD (The -q stops noise we just go by exit code)

if (system("wget -N -q $EGD_source/$EGD_file") != 0) {
	print STDERR "Could not open tournament list EGD file\n";
	exit 10;
}

# If file is the same as the old file then we don't need to do anything, return 0
# to the shell. (Note cmp gives a non-zero exit code if it can't find the file
# or the files differ)

exit 0 if compare($EGD_file, $old_file) == 0;

# Open the database
# Read the list of tournaments and dates

$Database = DBI->connect("DBI:mysql:ratinglist:britgo.org", "rlupd", "RL update");

unless ($Database)  {
	print STDERR "Cannot open rating list database\n";
	exit 11;
}

$sfh = $Database->prepare("select tcode,tdate from tournament");
$sfh->execute;

# We read the date straight in as MySQL format as that's what we plug in

while (my @row = $sfh->fetchrow_array)  {
	my ($tcode, $tdate) = @row;
	$Tourn_dates_my{$tcode} = $tdate;
}

# Now repeat that for the calibration data

$sfh = $Database->prepare("select cdate,shodan,onestone from calibration order by cdate");
$sfh->execute;

while (my @row = $sfh->fetchrow_array)  {
	my ($cdate, $shodan, $onestone) = @row;
	my $gdate = Mysqldate_to_gmtime($cdate);
	push @Calibrations, {MD => $cdate, GD => $gdate, SH => $shodan+0, ONE => $onestone+0.0 };	
}

# Open grabbed file for reading.

unless (open(EGDF, $EGD_file))  {
	print STDERR "Cannot open fetched EGD database\n";
	exit 12;
}

while (<EGDF>)  {
	chop;
	next unless /^\s*(\d+)\s+(.*?)\s+([A-Z]{2})\s+(\w+)\s+(\d+)([kdp])\s+(\S+)\s+(\d+)\s+(\d+)\s+(\w+)/;
	my ($pin,$name,$count,$club,$grade,$gradeletter,$ngrade,$gor,$nt,$lt) = ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10);
	next unless $count eq 'UK';
	next unless $name =~ /^(\S+)\s(\S+)$/;
	my ($first, $last) = ($2,$1);
	my $qfirst = $Database->quote($first);
	my $qlast = $Database->quote($last);
	if ($gradeletter eq 'k')  {
		$grade = - $grade;
	}
	elsif ($gradeletter eq 'd')  {
		$grade--;
	}
	else  {
		$grade += 6;
	}
	
	# Get date of tournament (in MySQL format)
	
	my $since;
	if (defined($Tourn_dates_my{$lt}))  {
		$since = $Tourn_dates_my{$lt};
	}
	else {
		$since = Tourn_date($lt);
	}
	
	# Get that in gmtime format
	# Calculate strength
	
	my $since_gm = Mysqldate_to_gmtime($since);
	
	my $ctindex = 0;	# Index in calibrations array
	my $min_distance = abs($Calibrations[$ctindex]->{GD} - $since_gm);
	my $next_index = 0;
    for my $cal (@Calibrations) {
    	my $dist = abs($cal->{GD} - $since_gm);
    	if ($dist < $min_distance)  {
    		$ctindex = $next_index;
    		$min_distance = $dist;
    	}
    	$next_index++;
    }
    my $cal = $Calibrations[$ctindex];
    my $strength = ($gor - $cal->{SH})/$cal->{ONE};
    $strength = sprintf "%.1f", $strength;
    my $reliable = $min_distance < $reliable_calibration_time ? 1 : 0;
    my $qclub = $Database->quote($club);
	my $qlt = $Database->quote($lt);
    my $qsince = $Database->quote($since);
	
	$sfh = $Database->prepare("select rank,rating,club,pin,ntourn,ltcode from player where first=$qfirst and last=$qlast");
	$sfh->execute;
	my @row = $sfh->fetchrow_array;
	if (@row)  {
		my ($dbrank,$dbrating,$dbclub,$dbpin,$dbnt,$dblt) = @row;
		if ($dbrank != $grade || $dbrating != $gor || $dbclub ne $club || $dbpin != $pin || $dbnt != $nt || $dblt ne $lt)  {
			$sfh = $Database->prepare("update player set changes=1,rank=$grade,rating=$gor,club=$qclub,pin=$pin,ntourn=$nt,ltcode=$qlt,reliable=$reliable,strength=$strength,since=$qsince where first=$qfirst and last=$qlast");
		}
	}
	else  {
		$sfh = $Database->prepare("insert into player (first,last,rank,strength,rating,club,since,pin,ntourn,reliable,ltcode,changes) values ($qfirst,$qlast,$grade,$strength,$gor,$qclub,$qsince,$pin,$nt,$reliable,$qlt,1)");		
	}
	$sfh->execute;
}
