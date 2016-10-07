<?php
//   Copyright 2016 John Collins

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

$Title = "Clash of ID";
include 'head.php';
$quser = htmlspecialchars($userid);
?>
<body>
<h1>Name Clash</h1>
<p>
<?php
print <<<EOT
Your proposed id of $quser clashes with an existing entry.
Please go back on your browser and try again.
EOT;
?>
</p>
</body>
</html>
