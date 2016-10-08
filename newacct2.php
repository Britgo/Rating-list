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

// Clog up the works for spammers

if (isset($_POST["turnoff"]) || !isset($_POST["turnon"]))  {
	system("sleep 60");
	exit(0);
}

include 'php/rlerr.php';
include 'php/opendb.php';
include 'php/genpasswd.php';
include 'php/newaccemail.php';

$userid = $_POST["userid"];
$passw1 = $_POST["passw1"];
$passw2 = $_POST["passw2"];
$email = $_POST["email"];

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
$ret = mysql_query("select count(*) from logins where user='$quserid'");
if (!$ret)  {
    $Title = "Database error";
    $mess = mysql_error();
    include 'php/generror.php';
    exit(0);
}

$row = mysql_fetch_array($ret);
if  ($rew[0] != 0)  {
    $value = $userid;
    include 'php/nameclash.php';
    exit(0);
}

if (strlen($passw1) == 0)
    $passw1 = generate_password();

$qpassw = mysql_real_escape_string($passw1);
$qemail = mysql_real_escape_string($email);

$ret = mysql_query("INSERT INTO logins (user,password,email) VALUES ('$quserid','$qpassw','$qemail')");
if (!$ret)  {
    $Title = "Database insert user error";
    $mess = mysql_error();
    include 'php/generror.php';
    exit(0);
}

newaccemail($email, $userid, $passw1);
$Title = "Rating List Account Created";
include 'php/head.php';
?>
<body>
<?php 
print <<<EOT
<h1>$Title</h1>
<p>Your account `$userid' has been successfully created and should be receiving
a confirmatory email with the password.</p>

EOT;
?>
<p>Please <a href="index.html">click here</a> to go back to the admin page or <a href="logins.php">here</a> to go to the logins page.</p>
</body>
</html>
