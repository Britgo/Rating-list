#! /usr/bin/perl
#
# Reset the changed marker on players.
#
# Copyright John Collins 26/01/2011

use DBD::mysql;

$Database = DBI->connect("DBI:mysql:ratinglist", "rlupd", "RL update");

$sfh = $Database->prepare("UPDATE player SET changes=0");
$sfh->execute;
exit 0;
