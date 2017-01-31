#! /usr/bin/perl
#
# Reset the changed marker on players.
#
# Copyright John Collins 26/01/2011

use Config::INI::Reader;
use DBD::mysql;

$inicont = Config::INI::Reader->read_file('/etc/webdb-credentials');
$ldbc = $inicont->{ratinglist};
$Database = DBI->connect("DBI:mysql:$ldbc->{database}", $ldbc->{user}, $ldbc->{password}) or die "Cannot open DB";
$sfh = $Database->prepare("UPDATE player SET changes=0");
$sfh->execute;
exit 0;
