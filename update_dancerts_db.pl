#! /usr/bin/perl

use Config::INI::Reader;
use DBD::mysql;

$df = shift @ARGV;
die "No file name given\n" unless $df;
open(DF, $df) or die "Cannot open $df\n";

$inicont = Config::INI::Reader->read_file('/etc/webdb-credentials');
$ldbc = $inicont->{ratinglist};
$Database = DBI->connect("DBI:mysql:$ldbc->{database}", $ldbc->{user}, $ldbc->{password}) or die "Cannot open DB";
$sfh = $Database->prepare("delete from dancerts");
$sfh->execute;

while (<DF>)  {
	chop;
	my ($first,$last,$rank,$yr,$mon,$dy) = split;
	$rank--;
	my $qfirst = $Database->quote($first);
	my $qlast = $Database->quote($last);
	my $qdate = $Database->quote("$yr-$mon-$dy");
	$sfh = $Database->prepare("insert into dancerts (first,last,rank,cdate) values ($qfirst,$qlast,$rank,$qdate)");
	$sfh->execute;
}
