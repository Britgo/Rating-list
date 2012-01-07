#! /usr/bin/perl
#
# Update ratings list from last played file.
#
# Copyright John Collins 23/01/2011

use DBD::mysql;
use File::Copy;
use File::Compare;

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

$sfh = $Database->prepare("SELECT tcode,tdate FROM tournament");
$sfh->execute;

# We read the date straight in as MySQL format as that's what we plug in

while (my @row = $sfh->fetchrow_array)  {
	my ($tcode, $tdate) = @row;
	$Tourn_dates_my{$tcode} = $tdate;
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
	
    my $qclub = $Database->quote($club);
	my $qlt = $Database->quote($lt);
    my $qsince = $Database->quote($since);
	
	$sfh = $Database->prepare("SELECT first,last,rank,rating,club,ntourn,ltcode FROM player WHERE pin=$pin");
	$sfh->execute;
	my @row = $sfh->fetchrow_array;
	if (@row)  {
		my ($dbfirst, $dblast, $dbrank, $dbrating, $dbclub, $dbnt, $dblt) = @row;
		if ($dbfirst != $first || $dblast != $last || $dbrank != $grade || $dbrating != $gor || $dbclub ne $club || $dbnt != $nt || $dblt ne $lt)  {
			my $qfirst = $Database->quote($first);
			my $qlast = $Database->quote($last);
			$sfh = $Database->prepare("UPDATE player SET changes=1,first=$qfirst,last=$qlast,rank=$grade,rating=$gor,club=$qclub,ntourn=$nt,ltcode=$qlt,since=$qsince WHERE pin=$pin");
		}
	}
	else  {
		my $qfirst = $Database->quote($first);
		my $qlast = $Database->quote($last);
		$sfh = $Database->prepare("INSERT INTO player (first,last,rank,rating,club,since,pin,ntourn,ltcode,changes) VALUES ($qfirst,$qlast,$grade,$gor,$qclub,$qsince,$pin,$nt,$qlt,1)");		
	}
	$sfh->execute;
}

exit 1;
