<?php
$Title = 'Wrongly entered';
include 'head.php';
?>
<body>
<h1>File wrongly entered</h1>
<p>
This page has not been entered correctly. Please try again from a standard page
or start at the top by <a href="index.php">clicking here</a>.</p>
<?php
if (strlen($mess) != 0)  {
	$qmess = htmlspecialchars($mess);
	print <<<EOT
<p>The actual error message was $qmess.</p>

EOT;
}
?>
</body>
</html>
