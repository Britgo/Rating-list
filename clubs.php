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

function count_usage($ccode, $yrs)  {
    $qcode = mysql_real_escape_string($ccode);
    $q = "SELECT COUNT(*) FROM player WHERE club='$qcode'";
    if ($yrs > 0)
        $q .= " AND since >= DATE_SUB(CURRENT_DATE(),INTERVAL $yrs YEAR)";
    $ret = mysql_query($q);
    if (!$ret)
        return  htmlspecialchars(mysql_error());
    $row = mysql_fetch_array($ret);
    return  $row[0];
}

try {
   opendb();
}
catch (Rlerr $e) {
   $Title = $e->Header;
   $mess = $e->getMessage();
   include 'php/generror.php';
   exit(0);
}

$ret = mysql_query("SELECT code,name FROM club ORDER BY name");
if (!$ret)  {
    $Title = "Database error";
    $mess = mysql_error();
    include 'php/generror.php';
    exit(0);
}

$Title = "List of clubs";
include 'php/head.php';
?>
<body>
<script language="javascript" src="webfn.js"></script>
<script language="javascript">
function okdel(name, url)  {
   if  (!confirm("Do you really want to delete club " + name + " from the rating list system"))
      return;
   document.location = "delclub.php?clubcode=" + url;
}
</script>
<h1>Club codes/names on rating list system</h1>
<table cellpadding="3" cellspacing="5">
<tr>
   <th>Code</th>
   <th>Name</th>
   <th>Players</th>
   <th>Play < 2 years</th>
   <th>Actions</th>
</tr>
<?php
while  ($row = mysql_fetch_assoc($ret))  {
    $code = $row['code'];
    $name = $row['name'];
    $qcode = htmlspecialchars($code);
    $qname = htmlspecialchars($name);
    $ecode = urlencode($code);
    $p = count_usage($code, 0);
    $p2 = count_usage($code, 2);
    print <<<EOT
<tr>
    <td>$qcode</td>
    <td>$qname</td>
    <td>$p</td>
    <td>$p2</td>
    <td><a href="updclub.php?clubcode=$ecode" title="Update details for this club">Update</a>
    &nbsp;<a href="javascript:okdel('$qcode', '$ecode');" title="Remove this club from the system">Delete</a></td>
</tr>

EOT;
}
?>
</table>
<p>Please <a href="index.php">Click here</a> to return to the admin page or <a href="newclub.php">click here</a> to add a new club to the system.</p>
</body>
</html>
