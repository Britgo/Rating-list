#! /usr/bin/perl
#
# Generate the calibration entries in the database
#
# Copyright John Collins 22/01/2011

use DBD::mysql;
use File::Copy;
use File::Compare;

$EGD_source = "http://www.europeangodatabase.eu/EGD/EGD_2_0/downloads";
$EGD_file = "alleuro.html";
$old_file = "alleuro.html.save";

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

@sbits = stat $EGD_file;
@tbits = localtime($sbits[9]);

# OK open the database
# FIXME set user name and password to allow SELECT and INSERT ops

$Database = DBI->connect("DBI:mysql:ratinglist", "rlupd", "RL update");

unless ($Database)  {
	print "Cannot open rating list database\n";
	exit 11;
}

# Open grabbed file for reading.

unless (open(EGDF, $EGD_file))  {
	print "Cannot open fetched EGD database\n";
	exit 12;
}

$num = 0;
$sum_x = $sum_y = $sum_xx = $sum_xy = $sum_yy = 0.0;

while (<EGDF>)  {
	chop;
	next unless /^\s*\d+\s+.*\s+([A-Z]{2})\s+(\d+)([dkp])\s+(\d+)/i;
	my ($count,$grade,$gradeletter,$rating) = ($1,$2,$3,$4);
	if ($gradeletter eq 'k') {
		$grade = - $grade;
	}
	elsif ($gradeletter eq 'd') {
		$grade -= 1;
	}
	else {
		$grade += 6;
	}
	next if $grade <= -20;
	$num++;
	$sum_x += $grade;
    $sum_y += $rating;
    $sum_xx += $grade * $grade;
    $sum_xy += $grade * $rating;
    $sum_yy += $rating * $rating;
}
close EGDF;

$temp = $sum_xx * $num - $sum_x * $sum_x;
$one_stone = ($sum_xy * $num - $sum_x * $sum_y) / $temp;
$shodan = ($sum_y - $sum_x * $one_stone) / $num;

$qdate = $Database->quote(sprintf "%.4d-%.2d-%.2d", $tbits[5]+1900, $tbits[4]+1, $tbits[3]);
$sfh = $Database->prepare("select count(*) from calibration where cdate=$qdate");
$sfh->execute;
@row = $sfh->fetchrow_array;
if ($row[0] == 0)  {
	$sfh = $Database->prepare("insert into calibration (cdate,shodan,onestone) values ($qdate,$shodan,$one_stone)");
	$sfh->execute;
}
exit 1;
