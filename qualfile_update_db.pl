#! /usr/bin/perl
#
# Generate possible promotions and qualifications for championship files.
#
# Copyright John Collins 25/01/2011

use DBD::mysql;
use Time::Local;

sub Mysqldate_to_gmtime {
	my $mdate = shift;
	my ($yr,$mon,$day) = $mdate =~ /(\d{4})-(\d\d)-(\d\d)/;
	timegm(0,0,12,$day,$mon-1,$yr);
}

# Open the database
# Read the list of tournaments and dates
# We need read/write as we are resetting the "changed" flag.

$Database = DBI->connect("DBI:mysql:ratinglist:britgo.org", "rlupd", "RL update");

unless ($Database)  {
	print STDERR "Cannot open rating list database\n";
	exit 11;
}

# Generate possible promotion candidates
# First get the current folk their max rank and when they achieved it.

$sfh = $Database->prepare("SELECT first,last,MAX(rank),cdate FROM dancerts GROUP BY last,first");
$sfh->execute;

while (my @row = $sfh->fetchrow_array)  {
	my ($first, $last, $rank, $rdate) = @row;
	my $name = "$first $last";
	my $bdate = Mysqldate_to_gmtime($rdate);
	$Dancerts{$name} = {RANK => $rank, DATE => $bdate};
}

# Look at the results for people whose strength is 0.5D or better
# and the tourney date

$sfh = $Database->prepare("SELECT first,last,pin,strength,since,ltcode FROM player WHERE changes=1 AND strength > -0.5 AND since >= DATE_SUB(CURRENT_DATE, INTERVAL 2 YEAR) ORDER BY last,first");
$sfh->execute;

while (my @row = $sfh->fetchrow_array)  {
	my ($first,$last,$pin,$strength,$since,$lt) = @row;
	my $name = "$first $last";
	my $target = - 0.5;
	$target = $Dancerts{$name}->{RANK} + 0.5 if defined $Dancerts{$name};
	next if $strength < $target;
	my $qtcode = $Database->quote($lt);
	my $qtdate = $Database->quote($since);
	my $insh = $Database->prepare("SELECT COUNT(*) FROM posspromo WHERE pin=$pin AND tcode=$qtcode");
	$insh->execute;
	my ($already) = $insh->fetchrow_array;
	unless ($already != 0)  {
		$insh = $Database->prepare("INSERT INTO posspromo (pin,strength,tcode,tdate) VALUES ($pin,$strength,$qtcode,$qtdate)");
		$insh->execute;
	}
}

# Look at the results for people whose rating is 1900 or more
# add to the qualifiers for the relevant year


$sfh = $Database->prepare("SELECT pin,rating,ltcode,since FROM player WHERE changes=1 AND rating>=1900");
$sfh->execute;

while (my @row = $sfh->fetchrow_array)  {
	my ($pin,$rating,$lt,$since) = @row;
	my $bdate = Mysqldate_to_gmtime($since);
	my @tbits = gmtime($bdate);
	my $qyear = $tbits[5] + 1900;
	$qyear-- if $tbits[4] < 3;
	my $qtcode = $Database->quote($lt);
	my $qtdate = $Database->quote($since);
	my $insh = $Database->prepare("SELECT COUNT(*) FROM qualifiers WHERE pin=$pin AND tcode=$qtcode");
	$insh->execute;
	my ($already) = $insh->fetchrow_array;
	unless ($already != 0)  {
		$insh = $Database->prepare("INSERT INTO qualifiers (pin,rating,tcode,tdate,qualyear) VALUES ($pin,$rating,$qtcode,$qtdate,$qyear)");
		$insh->execute;
	}
}