#! /usr/bin/perl
#
# Generate qualifications for championship.
#
# Copyright John Collins 25/01/2011

use DBD::mysql;
use Time::Local;

sub Mysqldate_to_gmtime {
	my $mdate = shift;
	my ($yr,$mon,$day) = $mdate =~ /(\d{4})-(\d\d)-(\d\d)/;
	timegm(0,0,12,$day,$mon-1,$yr);
}

sub spewline {
	my $tcs = shift;
	my @tcodes = @$tcs;
	my $ftc = $tcodes[0];
	my $first = $ftc->{F};
	my $last = $ftc->{L};
	my $pin = $ftc->{P};

	# Create name and link
	
	my $name = "$first $last";
	$name =~ tr/_/ /;
	$name = "<a href=\"http://www.europeangodatabase.eu/EGD/Player_Card.php?key=$pin\">$name</a>";

	print <<END;
<li>$name after

END

	# Create list of links to tournaments with names
	
	my @tlinks;
	
	for my $tc (@tcodes)  {
		my $tcode = $tc->{T};
		my $descr = $Tourn_dates_my{$tcode}->{DESCR};
		my $link = "<a href=\"http://www.europeangodatabase.eu/EGD/Tournament_Card.php?&key=$tcode\">$descr</a>";
		push @tlinks, $link;	
	}
	
	# Try to be pretty.
	
	my $lastt = pop @tlinks;
	print join(",\n", @tlinks), " and\n" if  $#tlinks >= 0;
	print "$lastt\n";
}


my $qualifiers_list = 'qualifiers.html';
@month_full_names = qw/January February March April May June July August September October November December/;

# Get the qualifying year as the argument otherwise default
# to last year if it is before April this year or this year after April

$Qualyear = shift @ARGV;

if ($Qualyear < 2010)  {
	my @tbits = localtime(time);
	$Qualyear = $tbits[5] + 1900 - 1;
	$Qualyear++ if $tbits[4] >= 3;
}
$Champ_year = $Qualyear + 1;

# Open the database

$Database = DBI->connect("DBI:mysql:ratinglist:britgo.org", "rluser", "Get Ratings");

unless ($Database)  {
	print STDERR "Cannot open rating list database\n";
	exit 11;
}

# Read list of tournament names and dates

$sfh = $Database->prepare("select tcode,tdate,country,description from tournament");
$sfh->execute;

while (my @row = $sfh->fetchrow_array)  {
	my ($tcode, $tdate, $tcount, $tdescr) = @row;
	my $gdate = Mysqldate_to_gmtime($tdate);
	$Tourn_dates_my{$tcode} = { MD => $tdate, GD => $gdate, CNTRY => $tcount, DESCR => $tdescr };
}

# Now create the qualifiers list.

unless (open(QUAL, ">$qualifiers_list"))  {
	print STDERR "Cannot open output file '$qualifiers_list'\n";
	exit 20;
}

# Get time when list was compiled to insert into output

if (my @rlstat = stat "alleuro_lp.html") {
	$rltime = $rlstat[9];
}
else {
	$rltime = time();
}
@rldate = localtime($rltime);
$cal_day = $rldate[3];
$cal_month = $month_full_names[$rldate[4]];
$cal_year = $rldate[5] + 1900;
$cal_th = substr("thstndrdththththth", ($cal_day % 10)*2, 2);
$cal_th = "th" if $cal_day >= 11 && $cal_day <= 13;
$cal_date = "$cal_day$cal_th $cal_month $cal_year";

select QUAL;

print <<END;
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html lang="en">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<title>Provisional qualifiers for the $Champ_year British Go Championship</title>
<link rel="stylesheet" title="BGA stylesheet" href="bga.css" type="text/css">
</head>

<!-- Warning, this page is automatically generated. If you edit it, your changes will be 
lost the next time the rating list is updated. If you need anything changed you will
have to ask the web team. -->

<body  text="#000000" bgcolor="#FFFF99" link="#0000CC" alink="#0000CC" vlink="#000066">

<h1>Provisional qualifiers for the $Champ_year British Go Championship</h1>

<p>Based on the
<a href="http://www.europeangodatabase.eu/EGD/EGF_rating_system.php">European rating list</a>
up to $cal_date.</p>

<p><strong>This page only checks the rating part of the qualification conditions.
It is unable to check the &#8216;played in all rounds&#8217; rule and
the nationality and BGA membership rules.
Manual confirmation is needed that you have qualified.</strong></p>

<p>The list shows players from the UK rating list who either first achieved an EGF rating at or
above 1900 in $Qualyear after 
the tournament(s) shown against their name.
Click the name link to see their rating graph.
Click the tournament name link to see the results table.</p>

<ul>
END

# This is a database query to fetch the tournament codes and get the players name from the pin

$sfh = $Database->prepare("SELECT first,last,player.pin,tcode FROM player,qualifiers WHERE qualyear=$Qualyear AND player.pin=qualifiers.pin ORDER BY last,first,tdate");
$sfh->execute;

$count = 0;
$lastpin = -10;
@tcodes = ();
while (my @row = $sfh->fetchrow_array)  {
	my ($first, $last, $pin, $tcode) = @row;
	
	# If we're talking about someone different, spew out the blurb on the
	# previous guy if any
	
	if ($pin != $lastpin)  {
		unless ($#tcodes < 0)  {
			spewline(\@tcodes);
			@tcodes = ();
		}
		$lastpin = $pin;
		$count++;
	}
	push @tcodes, {F => $first, L => $last, P => $pin, T => $tcode} if defined $Tourn_dates_my{$tcode};
}

spewline(\@tcodes) if $#tcodes >= 0;


print <<END;
</ul>

<p>Total $count qualifiers.</p>
</body>
</html>
END
