#! /usr/bin/perl
#
# Generate possible promotions list from the database.
#
# Copyright John Collins 25/01/2011

use Config::INI::Reader;
use DBD::mysql;

$outfile = "possible_promotions.txt";

unless (open(OUTF, ">$outfile"))  {
	print STDERR "Cannot open output file $outfile\n";
	exit 10;
}

# Open the database

$inicont = Config::INI::Reader->read_file('/etc/webdb-credentials');
$ldbc = $inicont->{ratinglist};
$Database = DBI->connect("DBI:mysql:$ldbc->{database}", $ldbc->{user}, $ldbc->{password}) or die "Cannot open DB";

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
