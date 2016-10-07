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

include 'php/rlerr.php';
include 'php/opendb.php';

if (!isset($_POST['user_id']) || !isset($_POST['passwd']))  {
    $mess = "No user id";
    include 'php/wrongentry.php';
    exit(0);
}

$userid = $_POST['user_id'];
$passwd = $_POST['passwd'];

try {
	opendb();
}
catch (Rlerr $e) {
   $Title = $e->Header;
   $mess = $e->getMessage();
   include 'php/generror.php';
   exit(0);
}

$quserid = mysql_real_escape_string($userid);
$ret = mysql_query("select user,password from logins where user='$quserid'");

// Check user known

if (!$ret || mysql_num_rows($ret) == 0)  {
	$Title = "Unknown User";
	$mess = "Unknown user $userid";
	include 'php/generror.php'; 
	exit(0);
}

// Verify password

if (!($row = mysql_fetch_assoc($ret)) || $passwd != $row['password'])  {
	$Title = 'Incorrect password';
	include 'php/head.php';
	print <<<EOT
<body>
<h1>Incorrect Password</h1>
<p>The password is not correct.
Please <a href="index.php" title="Go back to home page">click here</a> to return to the top.
</p>
</body>
</html>
EOT;
	exit(0);
}

// Set up session cookie

ini_set("session.gc_maxlifetime", "604800");
$phpsessiondir = $_SERVER["DOCUMENT_ROOT"] . "/phpsessions";
if (is_dir($phpsessiondir))
	session_save_path($phpsessiondir);
session_set_cookie_params(604800);
session_start();
$_SESSION['user_id'] = $userid;
setcookie("user_id", $userid, time()+60*60*24*60, "/");
?>
<html>
<head>
<title>Login OK</title>
</head>
<body onload="onl();">
<script language="javascript">
function onl() {
<?php
$prev = $_SERVER['HTTP_REFERER'];
if (strlen($prev) == 0 || preg_match('/newacct/', $prev) != 0)
	$prev = 'index.php';
print <<<EOT
	document.location = "$prev";

EOT;
?>
}
</script>
</body>
</html>