#! /usr/bin/perl
#
# Generate the rating list file from the local database.
#
# Copyright John Collins 25/01/2011

use DBD::mysql;
use Time::Local;
use Getopt::Long;

sub Mysqldate_to_gmtime {
	my $mdate = shift;
	my ($yr,$mon,$day) = $mdate =~ /(\d{4})-(\d\d)-(\d\d)/;
	timegm(0,0,12,$day,$mon-1,$yr);
}

$rating_list_file = "list";
$limit = 0;
my $reduced;

GetOptions("output=s" => \$rating_list_file, "limit=i" => \$limit, "reduced" => \$reduced);

$rating_list_file .= '.html' unless $rating_list_file =~ /\.html$/;
$rating_list_file = "/var/www/bgasite/ratings/$rating_list_file" unless $rating_list_file =~ m;/;;
if  ($limit > 0)  {
    $limit = " LIMIT $limit";
}
else {
    $limit = "";
}

@month_names = qw/Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec/;
@month_full_names = qw/January February March April May June July August September October November December/;

# This is the directory where we work in

$rating_scripts = "/var/www/ratings/scripts";

# Select that directory in case of any doubt

unless (chdir $rating_scripts)  {
	print STDERR "Could not open rating list directory\n";
	exit 9;
}

# OK open the database

$Database = DBI->connect("DBI:mysql:ratinglist:britgo.org", "rluser", "Get Ratings");

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

# Read list of club names

$sfh = $Database->prepare("SELECT code,name FROM club");
$sfh->execute;

while (my @row = $sfh->fetchrow_array)  {
	$Clubs{$row[0]} = $row[1];
}

# Get the last shodan rating and one stone from the calibration

$sfh = $Database->prepare("SELECT shodan,onestone FROM calibration ORDER BY cdate DESC LIMIT 1");
$sfh->execute;
if (my @row = $sfh->fetchrow_array) {
	$shodan = $row[0];
	$onestone = $row[1];
}

# Ready to start generating list

unless  (open(RL, ">$rating_list_file"))  {
	print STDERR "Cannot create rating list file\n";
	exit 12;
}

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

select RL;

print <<END;
<div style="text-align: center;">(Based on the
<a href="http://www.europeangodatabase.eu/EGD/EGF_rating_system.php">European rating list</a>
of $cal_date.)</div>
END

if  ($reduced)  {
    print <<END;
<table border="1" cellpadding="4" id="ratingtable">
<tr>
  <th class="l">Name</th>
  <th>Grade</th>
  <th>Rating</th>
  <th>Strength</th>
  <th class="l">Club</th>
</tr>
END
}
else  {
    print <<END;
<p>The <a href="http://www.britgo.org/ratings/krfaq.html">ratings FAQ</a> explains this table, and how to use the information it contains.</p>

<p>You can get a graph of a player&#8217;s rating history by clicking on their name in the list below.
You can see details of the last tournament the player attended by clicking on
the <b>since</b> column.</p>

<p>You can also reorder the list according to the criteria at the head of the column
in ascending or descending order by clicking on the <b>+</b> or <b>-</b> link at the
head or foot of the column.</p>

<p>If you notice any errors in the data here, please report them to the <a href="mailto:results\@britgo.org">tournament results officer</a>, <a href="http://www.britgo.org/ratings/krfaq.html#errors">as explained in the FAQ</a>.</p>

<table border="1" cellpadding="4" id="ratingtable">
<thead>
<tr>
<th class="l">sort <a href='javascript:sortTable(0, 1)'>+</a>/<a href='javascript:sortTable(0, -1)'>-</a></th>
<td><a href='javascript:sortTable(1, 1)'>+</a>/<a href='javascript:sortTable(1, -1)'>-</a></td>
<td><a href='javascript:sortTable(2, 1)'>+</a>/<a href='javascript:sortTable(2, -1)'>-</a></td>
<td><a href='javascript:sortTable(3, 1)'>+</a>/<a href='javascript:sortTable(3, -1)'>-</a></td>
<td><a href='javascript:sortTable(4, 1)'>+</a>/<a href='javascript:sortTable(4, -1)'>-</a></td>
<td class="l"><a href='javascript:sortTable(5, 1)'>+</a>/<a href='javascript:sortTable(5, -1)'>-</a></td>
<td><a href='javascript:sortTable(6, 1)'>+</a>/<a href='javascript:sortTable(6, -1)'>-</a></td>
</tr>
<tr>
  <th class="l">Name</th>
  <th>Grade</th>
  <th>Rating</th>
  <th>Strength</th>
  <th title="Date when this player's rating last changed">Since</th>
  <th class="l">Club</th>
  <th title="Number of rated tournaments this player has ever competed in">Tours</th>
</tr>
</thead>

<tfoot>
<tr>
<th class="l">sort <a href='javascript:sortTable(0, 1)'>+</a>/<a href='javascript:sortTable(0, -1)'>-</a></th>
<td><a href='javascript:sortTable(1, 1)'>+</a>/<a href='javascript:sortTable(1, -1)'>-</a></td>
<td><a href='javascript:sortTable(2, 1)'>+</a>/<a href='javascript:sortTable(2, -1)'>-</a></td>
<td><a href='javascript:sortTable(3, 1)'>+</a>/<a href='javascript:sortTable(3, -1)'>-</a></td>
<td><a href='javascript:sortTable(4, 1)'>+</a>/<a href='javascript:sortTable(4, -1)'>-</a></td>
<td class="l"><a href='javascript:sortTable(5, 1)'>+</a>/<a href='javascript:sortTable(5, -1)'>-</a></td>
<td><a href='javascript:sortTable(6, 1)'>+</a>/<a href='javascript:sortTable(6, -1)'>-</a></td>
</tr>
</tfoot>

<tbody id="ratingdata">
END
}

# Loop over players

$sfh = $Database->prepare("SELECT first,last,pin,rank,rating,since,ltcode,ntourn,club FROM player WHERE suppress=0 AND since >= DATE_SUB(CURRENT_DATE, INTERVAL 2 YEAR) ORDER BY rating desc,last$limit");
$sfh->execute;

while (my @row = $sfh->fetchrow_array)  {
	my ($first,$last,$pin,$grade,$rating,$since,$lastt,$nt,$clubc) = @row;
	# Get name right plus link to EGD
	my $name = "$first $last";
	$name =~ tr/_/ /;
	$name = "<a href=\"http://www.europeangodatabase.eu/EGD/Player_Card.php?key=$pin\">$name</a>";
	# Get grade right
	
	my $gc = $grade < -20? ' class="ur"' : '';
	if ($grade < 0)  {
		$grade = -$grade;
		$grade .= 'k';
	}
	else {
		$grade++;
		$grade .= 'd';
	}
	
	# We don't need to fiddle with the rating
	# Get strength right
	
	my $strength = ($rating - $shodan) / $onestone;
	my $sc = $strength < -17.0? ' class="ur"' : '';
	
	if ($strength < -0.5)  {
		$strength = -20.0 if $strength < -20.0;
		$strength = sprintf "%4.1f k", -$strength;
	}
	else {
		$strength = sprintf "%4.1f d", $strength + 1.0;
	}
	
	# Now link to tournament results on EGD first converting date to version with
	# Month Name in.

	my $title = "";
	if (defined($Tourn_dates_my{$lastt}))  {
		my $tname = $Tourn_dates_my{$lastt}->{DESCR} . " [results]";
		$title = " title=\"$tname\"";
	}

	$since =~ s/(\d+)-(\d+)-(\d+)/($3+0)."-$month_names[$2-1]-$1"/e;
	$since = "<a href=\"http://www.europeangodatabase.eu/EGD/Tournament_Card.php?&key=$lastt\"$title>$since</a>";
	
	if (defined($Clubs{$clubc}))  {
		$clubc = $Clubs{$clubc};
	}
	else {
		$clubc = "Unknown: $clubc";
		$Unknown_clubs{$clubc} = 1;
	}
	print <<END;
<tr>
  <td class="l">$name</td>
  <td$gc>$grade</td>
  <td>$rating</td>
  <td$sc>$strength</td>
END
       print "<td>$since</td>\n" unless $reduced;
        print "<td class=\"l\">$clubc</td>\n";
        print "<td>$nt</td>\n" unless $reduced;
        print "</tr>\n";
}

if  ($reduced)  {
    print <<END;
</table>

END
}
else  {
    print <<END;
</tbody></table>

<p>On the last run, an average European shodan rating (<var>r</var>) is $shodan, and
an average number of European rating points per one grade difference (<var>g</var>) is $onestone.</p>

<p>Strength is calculated using <var>strength</var> = (<var>rating</var> - <var>r</var>) / <var>g</var>. The <a href="http://www.britgo.org/ratings/krfaq.html#techie">technical section of the FAQ</a> contains a more detailed explanation.</p>

END
}

@Uckeys = sort keys %Unknown_clubs;

if ($#Uckeys >= 0)  {
    if  (open(MG, "|mail -s 'Unknown club codes' geoff\@kaniuk.co.uk jmc\@xisl.com"))  {
        print MG <<END;
The rating list generation routine hit the following unknown club codes:

END
       print MG join("\n", @Uckeys);
        print MG "\n\nThey have been put in with Unknown club for the time being.\n";
        close MG;
    }
}

exit 0;
