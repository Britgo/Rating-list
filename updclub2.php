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

if (!isset($_POST["clubcode"]) || !isset($_POST["name"]))  {
    $mess = "No code or name";
    include 'php/wrongentry.php';
    exit(0);
}

include 'php/rlerr.php';
include 'php/opendb.php';

$clubcode = $_POST["clubcode"];
$name = $_POST["name"];

try {
	opendb();
}
catch (Rlerr $e) {
   $Title = $e->Header;
   $mess = $e->getMessage();
   include 'php/generror.php';
   exit(0);
}

$qclubcode = mysql_real_escape_string($clubcode);
$qname = mysql_real_escape_string($name);
$ret = mysql_query("UPDATE club SET name='$qname' WHERE code='$qclubcode'");
if (!$ret)  {
    $Title = "Database error";
    $mess = mysql_error();
    include 'php/generror.php';
    exit(0);
}
$hcode = htmlspecialchars($clubcode);
$hname = htmlspecialchars($name);

$Title = "Club Created";
include 'php/head.php';
?>
<body>
<?php 
print <<<EOT
<h1>$Title</h1>
<p>The club code $hcode has been renamed $hname.</p>

EOT;
?>
<p>Please <a href="index.html">click here</a> to go back to the admin page or <a href="clubs.php">here</a> to go to the clubs page.</p>
</body>
</html>
