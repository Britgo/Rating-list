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

$Title = "BGA Rating List Club Name";
include 'php/rlerr.php';
include 'php/opendb.php';
try {
	opendb();
}
catch (Rlerr $e)  {
    $Title = $e->Header;
    $mess = $e->getMessage();
    include 'php/generror.php';
	exit(0);
}

$ret = mysql_query("SELECT code FROM club");
if (!$ret)  {
    $Title = "Database error";
    $mess = mysql_error();
    include 'php/generror.php';
    exit(0);
}

$clubcodes = array();
while  ($row = mysql_fetch_array($ret))
    array_push($clubcodes, strtolower($row[0]));

include 'php/head.php';
?>
<body>
<script language="javascript" src="webfn.js"></script>
<script language="javascript">
<?php
//  Set up list of existing codes to check against
print "Existing_codes = new Array();\n";
foreach ($clubcodes as $code)
    print "Existing_codes['$code'] = 1;\n";
?>

function formvalid()
{
    var form = document.cform;
    var codeval = form.clubcode.value;
    if  (!/^\w+$/.test(codeval))  {
        alert("No valid code given");
      	return  false;
    }
    if (Existing_codes[codeval.toLowerCase()])  {
        alert("Code " + codeval + " already exists");
        return  false;
    }
    if (codeval.length != 4 && !confirm("Codes are usually 4 characters long - OK"))
        return  false;
    if  (!nonblank(form.name.value))  {
        alert("No club name address given");
        return  false;
    }
    return true;
}
</script>
<h1>Set up new account on rating list database</h1>
<p>Please use the form below to set up an account on the rating list database.
You will only need an account if you want to amend details on the database.
</p>
<form name="cform" action="newclub2.php" method="post" enctype="application/x-www-form-urlencoded" onsubmit="javascript:return formvalid();">
<table cellpadding="5" cellspacing="5" border="0">
<tr><td>Club Code</td>
<td><input type="text" name="clubcode" size="4"></td></tr>
<tr><td>Name</td><td><input type="text" name="name"></td></tr>
</table>
<p>
<input type="submit" name="subm" value="Create Club">
</p>
</form>
</body>
</html>
