#! /usr/bin/perl
#
# Generate the flat file tournament list from the local database.
#
# Copyright John Collins 22/01/2011

use DBD::mysql;

# This is the directory where we work in

$rating_scripts = "/var/www/ratings/scripts";

# This the name of the generated file

$outfile = "tournament_names.txt";

# Select that directory in case of any doubt

unless (chdir $rating_scripts)  {
	print STDERR "Could not open rating list directory\n";
	exit 9;
}

# OK open the database

$Database = DBI->connect("DBI:mysql:ratinglist:britgo.org", "rluser", "Get Ratings");

unless ($Database)  {
	print "Cannot open rating list database\n";
	exit 11;
}

$sfh = $Database->prepare("select tcode,class,country,description from tournament order by tdate desc");
$sfh->execute;

unless (open(OUTF, ">$outfile"))  {
	print STDERR "Cannot create output file\n";
	exit 12;
}
select OUTF;

while (@row = $sfh->fetchrow_array)  {
	print join("\t", @row),"\n";
}
