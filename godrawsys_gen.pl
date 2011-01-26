#! /usr/bin/perl
#
# Generate qualifications for championship.
#
# Copyright John Collins 25/01/2011

use DBD::mysql;

# Open the database

$Outfile = "/var/www/bgasite/godrawsys/GoPlayers.gdi";

$Database = DBI->connect("DBI:mysql:ratinglist:britgo.org", "rluser", "Get Ratings");

unless ($Database)  {
	print STDERR "Cannot open rating list database\n";
	exit 11;
}

# Grab club codes map

$sfh = $Database->prepare("select code,name from club");
$sfh->execute;

while (my @row = $sfh->fetchrow_array)  {
	$Clubs{$row[0]} = $row[1];
}

unless (open(GDS, ">$Outfile"))  {
	print STDERR "Cannot open open output file $Outfile\n";
	exit 12;
}

print <<END;
NAME-FG GRADE   CLUB    COUNTRY RATING
END

# Now grab list in alphabetical order

$sfh = $Database->prepare("SELECT first,last,rank,rating,club FROM player WHERE suppress=0 ORDER BY rating DESC,last,first");
$sfh->execute;

while (my @row = $sfh->fetchrow_array)  {
	my ($first,$last,$grade,$rating,$club) = @row;
	my $name = "$first $last";
	$name =~ tr/_/ /;
	$name =~ s/\s{2,}/ /g;
	$name =~ s/\s+$//;
	if (defined $Clubs{$club}) {
		$club = $Clubs{$club};
	}
	else {
		$club = 'No Club';
	}
	if ($grade >= 0)  {
		$grade++;
		$grade .= "d";
	}
	else {
		$grade = -$grade;
		$grade .= "k";
	}
	print "$name\t$grade\t$club\tUK\t$rating\n";
}
