#! /usr/bin/perl
#
# Generate the rating list file from the local database.
#
# Copyright John Collins 25/01/2011

use DBD::mysql;
use Time::Local;

sub Mysqldate_to_gmtime {
	my $mdate = shift;
	my ($yr,$mon,$day) = $mdate =~ /(\d{4})-(\d\d)-(\d\d)/;
	timegm(0,0,12,$day,$mon-1,$yr);
}

@month_names = qw/Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec/;
@month_full_names = qw/January February March April May June July August September October November December/;

# This is the directory where we work in

$rating_scripts = "/var/www/ratings/scripts";
$rating_list_file = "../newlist.html";

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

$sfh = $Database->prepare("select tcode,tdate,country,description from tournament");
$sfh->execute;

while (my @row = $sfh->fetchrow_array)  {
	my ($tcode, $tdate, $tcount, $tdescr) = @row;
	my $gdate = Mysqldate_to_gmtime($tdate);
	$Tourn_dates_my{$tcode} = { MD => $tdate, GD => $gdate, CNTRY => $tcount, DESCR => $tdescr };
}

# Read list of club names

$sfh = $Database->prepare("select code,name from club");
$sfh->execute;

while (my @row = $sfh->fetchrow_array)  {
	$Clubs{$row[0]} = $row[1];
}

# Get the last shodan rating and one stone from the calibration

$sfh = $Database->prepare("select shodan,onestone from calibration order by cdate desc limit 1");
$sfh->execute;
if (my @row = $sfh->fetchrow_array) {
	$sd = $row[0];
	$og = $row[1];
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
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html lang="en">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<title>BGA rating list</title>
<link rel="stylesheet" title="BGA stylesheet" href="bga.css" type="text/css">
<style type="text/css">
#ratingdata a {
  color: black;
  text-decoration: none;
}
#ratingdata a:hover {
  color: blue;
  text-decoration: underline;
}
.ur {
  color: red;
}
#ratingtable .l {
  text-align: left;
}
#ratingtable td, #ratingtable th {
  text-align: right;
}

\@media print {
	#ratingtable tfoot {
		display: none;
	}
}
</style>
<script type="text/javascript">
// Inspiration for this code comes from <http://www.squarefree.com/bookmarklets/pagedata.html#sort_table>.
function insertAtTop(parent, child) {
	if (parent.childNodes.length) {
		parent.insertBefore(child, parent.childNodes[0]);
	} else {
		parent.appendChild(child);
	}
}

function compareRows(a, b) {
	if(a.sortKey==b.sortKey) return 0;
	return (a.sortKey<b.sortKey) ? g_order : -g_order;
}

function trim(s) {
	var start = 0;
	var end = s.length;
	while (s[start]==' ') {
		++start;
	}
	while (s[end]==' ') {
		--end;
	}
	return s.substr(start, end + 1);
}

function getText(e) {
	if (e.nodeType == 3) { // Text node
		return e.data;
	} else if (e.nodeType == 1) { // Element node
		var child = e.firstChild;
		var ans = '';
		while (child != null) {
			ans += getText(child);
			child = child.nextSibling;
		}
		return ans;
	}
}

function sortTable(columnNo, order) {
	var tableBody, rows, i;
	g_order = order;
	tableBody = document.getElementById('ratingdata');
	rows = new Array();
	for(i = 0; i<tableBody.rows.length; ++i) {
		rows[i] = tableBody.rows[i];
		var temp = trim(getText(rows[i].cells[columnNo]));

		if (columnNo==0) { // Player name - make it sort on last name
			var j = temp.lastIndexOf(' ');
			if (i >= 0) {
				rows[i].sortKey = temp.slice(j + 1) + ' ' + temp.slice(0, j);
			} else {
				rows[i].sortKey = temp;
			}
		} else if (columnNo==1 || columnNo==3) { // grade or strength.
			if (temp.charAt(temp.length - 1).toLowerCase() == 'k') {
				rows[i].sortKey = -Number(temp.slice(0, temp.length - 1));
			} else {
				rows[i].sortKey = Number(temp.slice(0, temp.length - 1)) - 1;
			}
		} else if (columnNo==4) { // Date TODO
			var bits = temp.split('-');
			var month = -1
			switch (bits[1]) {
				case "Jan": month = 0; break;
				case "Feb": month = 1; break;
				case "Mar": month = 2; break;
				case "Apr": month = 3; break;
				case "May": month = 4; break;
				case "Jun": month = 5; break;
				case "Jul": month = 6; break;
				case "Aug": month = 7; break;
				case "Sep": month = 8; break;
				case "Oct": month = 9; break;
				case "Nov": month = 10; break;
				case "Dec": month = 11; break;
			}
			rows[i].sortKey = new Date(bits[2], month, bits[0]);
		} else if (columnNo==5) { // Club
			rows[i].sortKey = temp;
		} else { // The numeric columns
			rows[i].sortKey = Number(temp);
		}
	}
	rows.sort(compareRows);
	for (i = 0; i<rows.length; ++i) {
		insertAtTop(tableBody, rows[i]);
	}
}
</script>
</head>

<body text="#000000" bgcolor="#FFFF99" link="#0000CC" alink="#0000CC" vlink="#000066">

<h1>BGA rating list</h1>

<p>Based on the
<a href="http://www.europeangodatabase.eu/EGD/EGF_rating_system.php">European rating list</a>
of $cal_date.</p>

<p>The <a href="http://www.britgo.org/ratings/krfaq.html">ratings FAQ</a> explains this table, and how to use the information it contains.</p>

<p>You can get a graph of a player&#8217;s rating history by clicking on their name in the list below.</p>

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

# Loop over players

$sfh = $Database->prepare("SELECT first,last,pin,rank,rating,strength,since,ltcode,ntourn,club,reliable FROM player WHERE suppress=0 AND since >= DATE_SUB(CURRENT_DATE, INTERVAL 2 YEAR) ORDER BY rating desc,last");
$sfh->execute;

while (my @row = $sfh->fetchrow_array)  {
	my ($first,$last,$pin,$grade,$rating,$strength,$since,$lastt,$nt,$clubc,$reliable) = @row;
	# Get name right plus link to EGD
	my $name = "$first $last";
	$name =~ tr/_/ /;
	$name = "<a href=\"http://www.europeangodatabase.eu/EGD/Player_Card.php?key=$pin\">$name</a>";
	# Get grade right
	my $sc = (!$reliable || $strength < -17.0)? ' class="ur"' : '';
	my $gc = (!$reliable || $grade < -20)? ' class="ur"' : '';
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
	
	if ($strength < -0.5)  {
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
	}
	print <<END;
<tr>
  <td class="l">$name</td>
  <td$gc>$grade</td>
  <td>$rating</td>
  <td$sc>$strength</td>
  <td>$since</td>
  <td class="l">$clubc</td>
  <td>$nt</td>
</tr>
END

}

print <<END;
</tbody></table>

<p>On the last run, an average European shodan rating (<var>r</var>) is $sd, and
an average number of European rating points per one grade difference (<var>g</var>) is $og.</p>

<p>Strength is calculated using <var>strength</var> = (<var>rating</var> - <var>r</var>) / <var>g</var>. The <a href="http://www.britgo.org/ratings/krfaq.html#techie">technical section of the FAQ</a> contains a more detailed explanation.</p>


<hr>
<p>This page is part of the <span class="cap">B</span>ritish <span class="cap">G</span>o
<span class="cap">A</span>ssociation <a href="http://www.britgo.org">web site</a>.</p>

</body>
</html>
END
exit 0;
