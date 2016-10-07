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

if ($logged_in)  {
   $Title = "Rating System Administration";
   include 'php/head.php';
   print <<<EOT
<body>
<h1>Rating list system Administration</h1>
<p>Please select one of the following options.</p>
<ol>
<li><a href="clubs.php">Click here to update club codes.</a></li>
<li><a href="players.php">Click here to amend the players list.</a></li>
<li><a href="logins.php">Click here to adjust the list of admins.</a></li>
<li><a href="ownacct.php">Click here to set your own password or email.</li>
<li><a href="logout.php">Log out</a>.</li>
</ol>

EOT;
}
else  {
   $Title = "You need to log in";
   include 'php/head.php';
   print <<<EOT
<body>
<script language="javascript" src="webfn.js"></script>
<h1>Ratings Administration login</h1>
<form name="lifm" action="login.php" method="post" enctype="application/x-www-form-urlencoded">

<p>Please log in with your user name <input type="text" name="user_id" id="user_id" size="10">
and password <input type="password" name="passwd" size="10"> and press <input type="submit" value="Login">.</p>
</form>

<p>If you have forgotten your password, please <a href="javascript:lostpw();" title="Get your lost password">Click here</a>.</p>

EOT;
}
?>
<p><a href="https://www.britgo.org">Click here to go to the main BGA site</a>.</p>
</body>
</html>
