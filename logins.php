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
include 'php/opendb.php';
include 'php/checklogged.php';

try {
   opendb();
}
catch (Rlerr $e) {
   $Title = $e->Header;
   $mess = $e->getMessage();
   include 'php/generror.php';
   exit(0);
}

$ret = mysql_query("SELECT user,email FROM logins ORDER BY user");
if (!$ret)  {
    $Title = "Database error";
    $mess = mysql_error();
    include 'php/generror.php';
    exit(0);
}

$Title = "List of admin logins";
include 'php/head.php';
?>
<body>
<script language="javascript" src="webfn.js"></script>
<script language="javascript">
function okdel(name, url)  {
   if  (!confirm("Do you really want to delete admin " + name + " from the rating list system"))
      return;
   document.location = "dellogin.php?uid=" + url;
}
</script>
<h1>Admin logins on rating list system</h1>
<table cellpadding="3" cellspacing="5">
<tr>
   <th>User</th>
   <th>Email</th>
   <th>Actions</th>
</tr>
<?php
while  ($row = mysql_fetch_assoc($ret))  {
    $u = $row['user'];
    $em = $row['email'];
    $qu = htmlspecialchars($u);
    $qem = htmlspecialchars($em);
    $eu = urlencode($u);
    print <<<EOT
<tr>
    <td>$qu</td>
    <td>$qem</td>
    <td><a href="updlogin.php?uid=$eu" title="Update details for this login">Update</a>
EOT;
    if ($u != $userid)
        print <<<EOT
&nbsp;<a href="javascript:okdel('$qu', '$eu');" title="Remove this login from the system">Delete</a>
EOT;
    print <<<EOT
</td>
</tr>

EOT;
}
?>
</table>
<p>Please <a href="index.php">Click here</a> to return to the admin page or <a href="newacct.php">click here</a> to add a new login to the system.</p>
</body>
</html>
