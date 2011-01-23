#! /usr/bin/perl
#
# Grab the EGD list of tournaments and adjust the database accordingly.
# This does not generate any output
#
# Copyright John Collins 22/01/2011

use DBD::mysql;
use Time::Local;
use File::Copy;
use File::Compare;

# This is where we might expect to get the EGD stuff from,
# the file name it is in, and a backup copy of the file.

$EGD_source = "http://www.europeangodatabase.eu/EGD/EGD_2_0/downloads";
$EGD_file = "tlist.html";
$old_file = "tlist.html.save";

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

# Grab the tournament file from EGD (The -q stops noise we just go by exit code)

if (system("wget -N -q $EGD_source/$EGD_file") != 0) {
	print STDERR "Could not open tournament list EGD file\n";
	exit 10;
}

# If file is the same as the old file then we don't need to do anything, return 0
# to the shell. (Note cmp gives a non-zero exit code if it can't find the file
# or the files differ)

exit 0 if compare($EGD_file, $old_file) == 0;

# OK open the database
# FIXME set user name and password to allow SELECT and INSERT ops

$Database = DBI->connect("DBI:mysql:ratinglist:britgo.org", "rlupd", "RL update");

unless ($Database)  {
	print "Cannot open rating list database\n";
	exit 11;
}

# Open grabbed file for reading.

unless (open(EGDF, $EGD_file))  {
	print "Cannot open fetched EGD database\n";
	exit 12;
}

# The file is in more or less date order in starting from the most recent date
# so we keep a count of duplicate rows and stop when we've had 10. This allows
# for a bit of mixing in recent dates. 

$duplicates = 0;

while (<EGDF>)  {
	chop;
	
	# This pattern matches a tournment code/class/country/description
	# if it doesn't match go onto the next record
	
	next unless /^\s+([A-Z]\d{6}[A-Z]?)\s+([ABC])\s+\(([A-Z][A-Z])\)\s+(.*)/;
	
	# Remember matched bits
	
	my ($code,$class,$count,$descr) = ($1,$2,$3,$4);
	
	# Decode date from tournament code
	
	my ($yr,$mn,$dy) = $code =~ /.(..)(..)(..)/;
	if ($yr > 50) {
		$yr += 1900;
	}
	else {
		$yr += 2000;
	}
	# Turn into a UNIX-style date
	my $date = timegm(0,0,12,$dy,$mn-1,$yr);
	
	# See how many rows in the database have that tournament code
	
	$qcode = $Database->quote($code);
	my $sfh = $Database->prepare("select count(*) from tournament where tcode=$qcode");
	$sfh->execute;
	@row = $sfh->fetchrow_array;
	if ($row[0] != 0) {
		# Already have that tournament code
		# Stop after 10 duplications
		# We use an exit code of 1 to denote we made changes
		$duplicates++;
		exit 1 if $duplicates > 10;
		next;
	}
	
	# Convert date to mysql-style dates and quote up
	my @tbits = localtime($date);
	my $qdate = $Database->quote(sprintf "%.4d-%.2d-%.2d", $tbits[5]+1900, $tbits[4]+1, $tbits[3]);
	
	# Quote all the other fields and insert into database
	
	my $qclass = $Database->quote($class);
	my $qcount = $Database->quote($count);
	my $qdescr = $Database->quote($descr);
	$sfh = $Database->prepare("insert into tournament (tdate,tcode,class,country,description) values ($qdate,$qcode,$qclass,$qcount,$qdescr)");
	$sfh->execute;
}

# Exit code of 1 means we made changes

exit 1;
