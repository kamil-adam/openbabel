package Acme::Import;
use Switch;
#use Spiffy qw( -Base );
use strict;

#przetwarza surowe dane na csv
sub lernu2csv {
	my $dir_in  = shift @_;
	my $dir_out = shift @_;
	my $regex   = shift @_ || '.*';
	opendir( DIR, $dir_in ) or die "can't opendir $dir_in: $!";
	my @files = readdir DIR;
	foreach my $file (@files) {
		if ( $file =~ /(($regex).*)\.lernu/ ) {
			#$logger->debug("lernu2csv file => $file, 1 => $1");
			my $dir_in_file  = $dir_in . '/' . $file;
			my $dir_out_file = $dir_out . '/' . $1 . '.csv';
			open( IN, "<", $dir_in_file )
			  or die "cannot open < $dir_in_file: $!";
			my @lines = (<IN>);
			close(IN);
			open( OUT, ">", $dir_out_file )
			  or die "cannot open > $dir_out_file: $!";
			foreach my $line (@lines) {
				$line =~ tr/,/;/;
				$line =~ s/ - /,/;
				print OUT $line;
			}
			close(OUT);
		}
	}
}
1;
