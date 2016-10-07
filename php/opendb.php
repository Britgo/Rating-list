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

// Class for exceptions during rating list creation handling

// Open database and throw error if not nice.

function opendb()
{

	//  CHANGE THESE AS REQUIRED!!!!

	$hostname = "localhost";	
	$username = "rlupd";
	$password = "RL update";
	$dbname = "ratinglist";
	
	if  (!mysql_connect($hostname, $username, $password)  ||  !mysql_select_db($dbname))  {
		$ecode = mysql_error();
		throw  new  Rlerr("Cannot open database, error was $ecode", "Database error");
	}
}

function closedb()
{
	mysql_close();
}
?>
