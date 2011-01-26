#! /usr/bin/perl
#
# Read the all.hst file from EGD and make sure we've got all possible
# qualifiers recorded.
#
# Copyright John Collins 26/01/2011

use DBD::mysql;
use Time::Local;

sub Mysqldate_to_gmtime {
	my $mdate = shift;
	my ($yr,$mon,$day) = $mdate =~ /(\d{4})-(\d\d)-(\d\d)/;
	timegm(0,0,12,$day,$mon-1,$yr);
}

# Grab the latest version of the all.hst file from EGD

$EGD_source = "http://www.europeangodatabase.eu/EGD/EGD_2_0/downloads";
$EGD_file = "hisgor.zip";
$uncomp_file = "all.hst";

unless (system("wget -N -q $EGD_source/$EGD_file") == 0)  {
	print STDERR "Cannot fetch EGD file\n";
	exit 20;
}
unless (system("unzip --qq -uoaa $EGD_file") == 0)  {
	print STDERR "Cannot unzip EGD file\n";
	exit 21;
}
unless (open(EGDF, $uncomp_file))  {
	print STDERR "Cannot open $uncomp_file\n";
	exit 22;
}

# Open the database
# Read the list of tournaments and dates
# We need read/write as we are resetting the "changed" flag.

$Database = DBI->connect("DBI:mysql:ratinglist:britgo.org", "rlupd", "RL update");

unless ($Database)  {
	print STDERR "Cannot open rating list database\n";
	exit 11;
}

# Read list of tournament names and dates

$sfh = $Database->prepare("SELECT tcode,tdate,country,description FROM tournament");
$sfh->execute;

while (my @row = $sfh->fetchrow_array)  {
	my ($tcode, $tdate, $tcount, $tdescr) = @row;
	my $gdate = Mysqldate_to_gmtime($tdate);
	$Tourn_dates_my{$tcode} = { MD => $tdate, GD => $gdate, CNTRY => $tcount, DESCR => $tdescr };
}

$lastpin = -10;
$skipping = 0;

while (<EGDF>)  {
	chop;
	next unless /^\s*(\d+)\s+.*([A-Z][A-Z])\s+\w+\s+\d+[kdp]\s+(\w+)\s+\d+\s+\d+\s+\d+\s+(\d+)/;
	my ($pin,$count,$tourn,$rating) = ($1,$2,$3,$4);
	next unless $count eq 'UK' and $rating >= 1900;
	if ($pin != $lastpin)  {
		$lastpin = $pin;
		$sfh = $Database->prepare("SELECT count(*) FROM player WHERE pin=$pin");
		$sfh->execute;
		my ($exists) = $sfh->fetchrow_array;
		$skipping = $exists == 0;
	}
	next if $skipping;
	next unless defined $Tourn_dates_my{$tourn};
	# Have we recorded this one?
	my $qtcode = $Database->quote($tourn);
	$sfh = $Database->prepare("SELECT count(*) FROM qualifiers WHERE PIN=$pin AND tcode=$qtcode");
	$sfh->execute;
	my ($exists) = $sfh->fetchrow_array;
	unless ($exists > 0)  {
		my $tdate = $Tourn_dates_my{$tourn}->{MD};
		my $bdate = $Tourn_dates_my{$tourn}->{GD};
		my @tbits = gmtime($bdate);
		my $qyear = $tbits[5] + 1900;
		$qyear-- if $tbits[4] < 3;
		my $qtdate = $Database->quote($tdate);
		$sfh = $Database->prepare("INSERT INTO qualifiers (pin,rating,tcode,tdate,qualyear) VALUES ($pin,$rating,$qtcode,$qtdate,$qyear)");
		$sfh->execute;
	}
}
close EGDF;
unlink $uncomp_file, $EGD_file;
