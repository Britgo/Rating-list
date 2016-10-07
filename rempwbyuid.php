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

// This is invoked from a subwindow so we don't do the frame emulation stuff.

include '../php/messerr.php';
include '../php/session.php';
include '../php/opendb.php';
include '../php/person.php';

if  (!isset($_GET['uid']))  {
   $Title = "No uid";
   include '../php/wrongentry.php';
   exit(0);
}
$userid = $_GET['uid'];
try {
	opendb();
	$pers = new Person($userid, "", true);
	$pers->fetchdetsfromalias();
}
catch (Messerr $e) {
   $Title = $e->Header;
	$mess = $e->getMessage();
	include '../php/generror.php';
	exit(0);
}

$em = $pers->Email;
$pw = $pers->get_passwd();

if (strlen($em) == 0)  {
   $Title = "No email set";
	$Mess = "Player {$player->display_name(false)} has no email address set up.";
}
elseif (strlen($pw) == 0)  {
   $Title = "No password set";
	$Mess = "Player {$player->display_name(false)} has no password set.";
}
else {
	$Title = "Reminder sent";
	$Mess = "Reminder was sent OK.";
	$fh = popen("REPLYTO=please_do_not_reply@britgo.org mail -s 'Go Message system email - password reminder' $em", "w");
	fwrite($fh, "Your userid is $userid.\n");
	fwrite($fh, "Your password is $pw\n");
	pclose($fh);
}
include '../php/head.php';
print <<<EOT
<body>
<h1>$Title</h1>
<p>$Mess</p>
EOT;
?>
<p>Please click <a href="javascript:self.close();">here</a> to close this window.</p>
</body>
</html>
