<?php
if (!isset($Title))
   $Title = 'System Error';
if (!isset($mess))
   $mess = 'Unknown problem';
$qpage = htmlspecialchars($_SERVER['REQUEST_URI']);
$qmess = htmlspecialchars($mess);
include 'head.php';
print <<<EOT
<body>
<h1>$Title</h1>
<p>Some problem has been detected going into the page:</p>
<p>$qpage</p>
<p>Please try again by starting at the top or by <a href="/index.php">clicking here</a>.</p>
<p>Please advise that the message given was</p>
<p>$qmess</p>

EOT;
?>
</body>
</html>
