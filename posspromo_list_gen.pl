#! /usr/bin/perl
#
# Generate possible promotions list from the database.
#
# Copyright John Collins 25/01/2011

use DBD::mysql;

$outfile = "possible_promotions.txt";

unless (open(OUTF, ">$outfile"))  {
	print STDERR "Cannot open output file $outfile\n";
	exit 10;
}

# Open the database

$Database = DBI->connect("DBI:mysql:ratinglist", "rluser", "Get Ratings");

unless ($Database)  {
	print STDERR "Cannot open rating list database\n";
	exit 11;
}

# Create list of possible promotions

$sfh = $Database->prepare("SELECT first,last,player.pin FROM player,posspromo WHERE player.pin=posspromo.pin ORDER BY last,first");
$sfh->execute;

select OUTF;
while (my @row = $sfh->fetchrow_array)  {
	my ($first,$last,$pin) = @row;
	my $name = "$first $last";
	$name =~ tr/_/ /;
	$name =~ s/\s{2,}/ /;
	$name =~ s/\s+$//;
	print "$name $pin\n";
}
