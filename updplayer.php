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
include 'php/checklogged.php';
include 'php/rlerr.php';
include 'php/opendb.php';

if  (!isset($_GET['pin']))  {
    $mess = "No pin given";
    include 'php/wrongentry.php';
    exit(0);
}

$updpin = $_GET['pin'];

try {
	opendb();
}
catch (Rlerr $e)  {
    $Title = $e->Header;
    $mess = $e->getMessage();
    include 'php/generror.php';
	exit(0);
}

$ret = mysql_query("SELECT first,last,club,suppress,email FROM player WHERE pin=$pin");
if (!$ret) {
    $Title = "Database error";
    $mess = mysql_error();
    include 'php/generror.php';
    exit(0);
}
if (mysql_num_rows($ret) == 0)  {
    $Title = "Unknown pin";
    $mess = "$pin is an unknown pin";
    include 'php/generror.php';
    exit(0); 
}
$row = mysql_fetch_assoc($ret);
$first = $row['first'];
$last = $row['last'];
$club = $row['club'];
$pin = $row['pin'];
$suppress = $row['suppress'];
$email = $row['email'];

$Title = "Update Player";
include 'php/head.php';
?>
<body>
<script language="javascript" src="webfn.js"></script>
<script language="javascript">
function formvalid()
{
    var form = document.pform;
    if  (!nonblank(form.name.value))  {
        alert("No name given");
        return  false;
    }
    return true;
}
</script>
<h1>Update player details on rating list database</h1>
<p>Please use the form below to update player details on the rating list database.</p>
<form name="pform" action="updplayer2.php" method="post" enctype="application/x-www-form-urlencoded" onsubmit="javascript:return formvalid();">
<table cellpadding="5" cellspacing="5" border="0">
<?php
print <<<EOT
<input type="hidden" name="pin" value="$pin">
<tr><td>Name</td><td><input type="text" name="name" value="$hqname"></td></tr>

EOT;
?>
</table>
<p>
<input type="submit" name="subm" value="Update player">
</p>
</form>
</body>
</html>
