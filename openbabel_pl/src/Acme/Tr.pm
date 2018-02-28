package Acme::Tr;

use File::Copy;
use Data::Dumper;
use Log::Log4perl qw(:easy);

#use Acme::Heap;
use Acme::CSVFacade;

Log::Log4perl->easy_init($DEBUG);
my $logger = Log::Log4perl->get_logger('acme.openbabel');

# parsuje ręcznie skompresowane utworzone pliki na pary
sub parse_man_csv {
	my $dir_in  = shift @_;
	my $dir_out = shift @_;
	my $regex   = shift @_ || '.*';
	my (@langs) = @_;
	my @handles;
	my $csv = Text::CSV->new( { binary => 1 } )
	  or die "Cannot use CSV: " . Text::CSV->error_diag();
	my @files = Acme::CSVFacade::readfiles $dir_in;
	foreach my $file (@files) {

		if ( $file =~ /(($regex).*)\.csv/ ) {
			foreach my $lang (@langs) {
				my $file_name = $dir_out . '/' . $1 . '.' . $lang . '.csv';
				open( my $handle, ">", $file_name )
				  or die "can't open $file_name : $!";
				push @handles, $handle;
			}

			my $dir_in_file = $dir_in . '/' . $file;
			my @rows        = Acme::CSVFacade::scan_all($dir_in_file);

			#$logger->debug("parse_man_csv rows => @rows");
			foreach my $row (@rows) {

				#$logger->debug("parse_man_csv row => @$row");
				my @columns = @$row;
				if ( $columns[0] ne "" ) {
					for ( my $i = 0 ; $i <= $#handles ; $i += 1 ) {
						my $handle = $handles[$i];
						my $pair = [ $columns[0], $columns[ $i + 1 ] ];

						#$logger->debug("parse_man_csv pair => @$pair");
						$csv->print( $handle, $pair );
						print $handle "\n";
					}
				}
			}
			foreach my $handle (@handles) {
				close $handle or die "can't close $handle : $!";
			}
		}
	}
}

sub scal_csv {
	$logger->debug('scal_csv ');
	my $dir_in  = shift @_;
	my $dir_out = shift @_;
	my $regex   = shift @_ || '.*';
	my $lang    = shift @_;
	my @files   = Acme::CSVFacade::readfiles $dir_in;
	my $m       = "($regex)\.$lang\.csv";
	$logger->debug("scal_csv m => $m");

	my @contains;
	foreach my $file (@files) {
		if ( $file =~ /$m/ ) {
			push @contains,
			  ( Acme::CSVFacade::readlines( $dir_in . '/' . $file ) );
		}
	}
	Acme::CSVFacade::writelines( $dir_out . '/' . $lang . '.csv', @contains );
}

#TODO nie działa
#generuje raport do nauki
sub report_generate {
	my $files_in = shift @_;
	my $file_out = shift @_;
	my $lambda   = shift @_;
	my (@langs)  = @_;
	my $size     = @langs;

	$logger->debug("report_generate langs $size @langs ");

	#przekonwertować plik na strukture csv
	my %rows_hash = ();
	for ( my $i = 0 ; $i < $size ; $i += 1 ) {
		my $lang = shift @langs;

		#przekonwertować plik na strukture csv
		$logger->debug("report_generate lang => $lang");
		my $file_name = $files_in . '/' . $lang . '.csv';
		$logger->debug("report_generate file_name => $file_name");
		my @rows =
		  Acme::CSVFacade::scan_all( $files_in . '/' . $lang . '.csv' );
		foreach my $row (@rows) {
			my $value = $rows_hash{ $row->[0] };

			#$logger->debug("______value => @$value") if ( !$value );
			$value = [ $row->[0] ] if ( !$value );

			$value->[ $i + 1 ] = $row->[1];

			#$logger->debug("report_generate value => @$value");
			$rows_hash{ $row->[0] } = $value;
		}
	}

	#przekonwertować hash na array
	my @rows = values %rows_hash;

	#$logger->debug("report_generate rows =>  @rows");

	Acme::CSVFacade::print_all( $file_out, @rows );
}

sub create_table {
	my $files_in = shift @_;
	my $file_out = shift @_;
	my (@langs)  = @_;
	my $size     = @langs;

	#przekonwertować plik na strukture csv
	my %rows_hash = ();
	for ( my $i = 0 ; $i < $size ; $i += 1 ) {
		my $lang = shift @langs;

		#przekonwertować plik na strukture csv
		$logger->debug("create_table lang => $lang");
		my $file_name = $files_in . '/' . $lang . '.csv';
		$logger->debug("create_table file_name => $file_name");
		my @rows =
		  Acme::CSVFacade::scan_all( $files_in . '/' . $lang . '.csv' );
		foreach my $row (@rows) {
			$value = [ $lang, @$row ];

			#$logger->debug("report_generate value => @$value");
			$rows_hash{ $row->[0] } = $value;
		}
	}

	#przekonwertować hash na array
	my @rows = values %rows_hash;

	#$logger->debug("report_generate rows =>  @rows");

	Acme::CSVFacade::print_all( $file_out, @rows );
}

1;
