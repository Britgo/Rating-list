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

if  (!isset($_GET['uid']))  {
    $mess = "No user given";
    include 'php/wrongentry.php';
    exit(0);
}

$upduser = $_GET['uid'];

try {
	opendb();
}
catch (Rlerr $e)  {
    $Title = $e->Header;
    $mess = $e->getMessage();
    include 'php/generror.php';
	exit(0);
}

$quserid = mysql_real_escape_string($upduser);
$ret = mysql_query("SELECT password,email FROM logins WHERE user='$quserid'");
if (!$ret) {
    $Title = "Database error";
    $mess = mysql_error();
    include 'php/generror.php';
    exit(0);
}
if (mysql_num_rows($ret) == 0)  {
    $Title = "Unknown user";
    $mess = "$upduser is an unknown user";
    include 'php/generror.php';
    exit(0); 
}
$row = mysql_fetch_assoc($ret);
$pw = $row['password'];
$em = $row['email'];
$hquserid = htmlspecialchars($upduser);
$hqpw = htmlspecialchars($pw);
$hqem = htmlspecialchars($em);

$Title = "Update Rating List Account";
include 'php/head.php';
?>
<body>
<script language="javascript" src="webfn.js"></script>
<script language="javascript">
function formvalid()
{
    var form = document.trform;
    if  (!nonblank(form.email.value))  {
        alert("No email address given");
        return  false;
    }
    if (form.passw1.value != form.passw2.value)  {
        alert("Passwords do not match");
        return  false;
    }
    return true;
}
</script>
<h1>Update account on rating list database</h1>
<p>Please use the form below to update an account on the rating list database.</p>
<form name="trform" action="updlogin2.php" method="post" enctype="application/x-www-form-urlencoded" onsubmit="javascript:return formvalid();">
<table cellpadding="5" cellspacing="5" border="0">
<?php
print <<<EOT
<input type="hidden" name="userid" value="$hquserid">
<tr><td>Password (leave blank to let system set it)</td>
<td><input type="password" name="passw1" value="$hqpw"></td></tr>
<tr><td>Confirm Password (likewise)</td>
<td><input type="password" name="passw2" value="$hqpw"></td></tr>
<tr><td>Email (must have)</td>
<td><input type="text" name="email" value="$hqem"></td></tr>

EOT;
?>
</table>
<p>
<input type="submit" name="subm" value="Update Account">
</p>
</form>
</body>
</html>
