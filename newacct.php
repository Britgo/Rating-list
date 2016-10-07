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

$Title = "BGA Rating List Account";
include 'php/rlerr.php';
include 'php/opendb.php';
try {
	opendb();
}
catch (Rlerr $e)  {
    $Title = $e->Header;
    $mess = $e->getMessage();
	exit(0);
}
?>
<body>
<script language="javascript" src="webfn.js"></script>
<script language="javascript">
function formvalid()
{
      var form = document.trform;
      if (form.turnoff.checked) {
      	alert("You didn't turn off the non-spammer box");
      	return false;
      }
      if (!form.turnon.checked) {
      	alert("You didn't turn on the non-spammer box");
      	return false;
      }
      if  (!/^\w+$/.test(form.userid.value))  {
      	alert("No valid userid given");
      	return  false;
      }
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
<?php include 'php/nav.php'; ?>
<h1>Apply for new account on rating list database</h1>
<p>Please use the form below to apply for an account on the rating list database.
You will only need an account if you want to amend details on the database.
</p>
<form name="trform" action="newacct2.php" method="post" enctype="application/x-www-form-urlencoded" onsubmit="javascript:return formvalid();">
<table cellpadding="5" cellspacing="5" border="0">
<tr><td>Userid (initials acceptable)</td>
<td><input type="text" name="userid"></td></tr>
<tr><td>Password (leave blank to let system set it)</td>
<td><input type="password" name="passw1"></td></tr>
<tr><td>Confirm Password (likewise)</td>
<td><input type="password" name="passw2"></td></tr>
<tr><td>Email (must have)</td>
<td><input type="text" name="email"></td></tr>
<tr><td colspan=2><input type="checkbox" name="turnoff" checked>
&lt;&lt; Because I'm not a spammer I'm turning this off and this on &gt;&gt;
<input type="checkbox" name="turnon"></td></tr>
</table>
<p>
<input type="submit" name="subm" value="Create Account">
</p>
</form>
</body>
</html>
