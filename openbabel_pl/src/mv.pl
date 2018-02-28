#!/usr/bin/perl

use File::Copy;

use Data::Dumper;
use Log::Log4perl qw(:easy);
Log::Log4perl->easy_init($DEBUG);
my $logger = Log::Log4perl->get_logger('pl.writeonly.perl.lernu2csv');

$logger->debug("$#ARGV");

my $dir = $ARGV[1] || '.';

$logger->debug("dir => $dir");
opendir( DIR, $dir ) or die "can't opendir $dir: $!";
my @files = readdir DIR;
foreach my $file (@files) {
	open( my $fh, "<", $file ) or die "cannot open < $file: $!";
	my $to_exec = 'sed -e s/\;/\;/g ' . "$file > ${file}new";
	$logger->debug("to_exec => $to_exec");
	exec( 'sed -e s/\;/\;/g ' . "$file > ${file}new" );
}

