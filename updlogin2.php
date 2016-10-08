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
include 'php/session.php';
include 'php/checklogged.php';
include 'php/opendb.php';
include 'php/genpasswd.php';
include 'php/newaccemail.php';

$upduser = $_POST["userid"];
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

if (strlen($passw1) == 0)
    $passw1 = generate_password();

$quserid = mysql_real_escape_string($upduser);
$qpassw = mysql_real_escape_string($passw1);
$qemail = mysql_real_escape_string($email);

$ret = mysql_query("UPDATE logins SET password='$qpassw',email='$qemail' WHERE user='$quserid'");
if (!$ret)  {
    $Title = "Database update user error";
    $mess = mysql_error();
    include 'php/generror.php';
    exit(0);
}

newaccemail($email, $userid, $passw1);
$Title = "Rating List Account Updated";
include 'php/head.php';
?>
<body>
<?php 
print <<<EOT
<h1>$Title</h1>
<p>The account `$userid' has been successfully updated and should be receiving
a confirmatory email with the password.</p>

EOT;
?>
<p>Please <a href="index.html">click here to go back to the admin page or <a href="logins.php">here to go to the logins page.</p>
</body>
</html>
