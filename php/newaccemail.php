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

function newaccemail($email, $userid, $passw)  {
	if (strlen($email) != 0)  {
		$fh = popen("REPLYTO=admin@ratings.britgo.org mail -s 'BGA rating list account created' $email", "w");
		fwrite($fh, "Please DO NOT reply to this message!!!\n\n");
		fwrite($fh, "A rating list account has been created for you on http://tournaments.britgo.org\n\n");
		fwrite($fh, "Your user id is $userid and your password is $passw\n\n"); 
		fwrite($fh, "Please log in and reset your password if you wish\n");
		pclose($fh);
	}
}
?>
