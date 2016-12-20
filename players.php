<?php
//   Copyright 2016 John Collins

// *****************************************************************************
// PLEASE BE CAREFUL ABOUT EDITING THIS FILE, IT IS SOURCE-CONTROLLED BY GIT!!!!
// Your changes may be lost or break things if you don't do it correctly!
// *****************************************************************************

//   This program is free software: you can redistribute it and/or modify
//   it under the terms of the GNU General Public License as published by
//   the Free Software Foundation, either version 3 of the License, or
//   (at your option) any later version.

//   This program is distributed in the hope that it will be useful,
//   but WITHOUT ANY WARRANTY; without even the implied warranty of
//   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//   GNU General Public License for more details.

//   You should have received a copy of the GNU General Public License
//   along with this program.  If not, see <http://www.gnu.org/licenses/>.

include 'php/session.php';
include 'php/rlerr.php';
include 'php/opendb.php';
include 'php/checklogged.php';

try {
   opendb();
}
catch (Rlerr $e) {
   $Title = $e->Header;
   $mess = $e->getMessage();
   include 'php/generror.php';
   exit(0);
}

$ret = mysql_query("SELECT code,name FROM club");
if (!$ret)  {
    $Title = "Database error";
    $mess = mysql_error();
    include 'php/generror.php';
    exit(0);
}

$clublookup = array();
while  ($row = mysql_fetch_assoc($ret))
    $clublookup[$row['code']] = $row['name'];

$ret = mysql_query("SELECT first,last,rank,rating,club,pin,suppress,email FROM player ORDER BY last,first,rank desc");
if (!$ret)  {
    $Title = "Database error";
    $mess = mysql_error();
    include 'php/generror.php';
    exit(0);
}

$Title = "List of players";
include 'php/head.php';
?>
<body>
<script language="javascript" src="webfn.js"></script>
<script language="javascript">
function okdel(name, pin)  {
   if  (!confirm("Do you really want to delete player " + name + " from the rating list system"))
      return;
   document.location = "delplayer.php?pin=$pin";
}
</script>
<h1>Players on rating list system</h1>
<table cellpadding="1" cellspacing="2">
<tr>
   <th>Name</th>
   <th>Rank</th>
   <th>Rating</th>
   <th>Club</th>
   <th>PIN</th>
   <th>Suppress</th>
   <th>Email</th>
   <th>Actions</th>
</tr>
<?php
while  ($row = mysql_fetch_assoc($ret))  {
    $first = $row['first'];
    $last = $row['last'];
    $rank = $row['rank'];
    $rating = $row['rating'];
    $club = $row['club'];
    $pin = $row['pin'];
    $suppress = $row['suppress'];
    $email = $row['email'];
    $name = htmlspecialchars("$first $last");
    if ($rank >= 0)
        $qrank = sprintf("%dD", $rank+1);
    else
        $qrank = sprintf("%dK", -$rank);
    if (isset($clublookup[$club]))
        $qclub = htmlspecialchars($clublookup[$club]);
    else
        $qclub = htmlspecialchars("Unknown club $club");
    $qsupp = $suppress? "Suppress": "&nbsp;";
    $qemail = htmlspecialchars($email);
    $qf = urlencode($first);
    $ql = urlencode($last);
    print <<<EOT
<tr>
    <td>$name</td>
    <td>$qrank</td>
    <td>$rating</td>
    <td>$qclub</td>
    <td>$pin</td>
    <td>$qsupp</td>
    <td>$qemail</td>
    <td><a href="updplayer.php?pin=$pin" title="Update details for this player">Update</a>
    &nbsp;<a href="javascript:okdel('$name', $pin);" title="Remove this player from the system">Delete</a></td>
</tr>

EOT;
}
?>
</table>
<p>Please <a href="index.php">Click here</a> to return to the admin page.</p>
</body>
</html>
