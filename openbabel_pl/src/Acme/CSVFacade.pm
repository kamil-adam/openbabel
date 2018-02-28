package Acme::CSVFacade;
use Switch;
use strict;
use Carp ();

#use Spiffy qw( -Base );
use strict;
use Text::CSV;
use Text::CSV::Hashify;
use Text::CSV::Separator;
use Text::CSV::Slurp;
use DBI;
use DBD::CSV;

use Exporter 'import';

use vars qw(@ISA @EXPORT_OK);
@ISA = qw(Exporter);

@EXPORT_OK = qw/scan_all print_all readlines writelines readfiles/;

#use Log::Log4perl qw(:easy);
#Log::Log4perl->easy_init($DEBUG);
#my $logger = Log::Log4perl->get_logger('Acme::CSVFacade');

sub scan_all {
	my $file = shift @_ || die "pusty file";
	print "scan_all file => $file";
	my $csv = Text::CSV->new( { binary => 1 } )
	  or die "Cannot use CSV: " . Text::CSV->error_diag();
	open( IN, "<", $file ) or die "$file: $!";
	my $row_ref = $csv->getline_all( \*IN );
	$csv->eof or $csv->error_diag();
	close(IN) or die "$file: $!";
	return @$row_ref;
}

sub print_all {
	my ( $file, @rows ) = @_;
	open OUT, ">", $file or die "$file: $!";
	my $csv = Text::CSV->new( { binary => 1 } )
	  or die "Cannot use CSV: " . Text::CSV->error_diag();
	for (@rows) {
		$csv->print( \*OUT, $_ );
		print OUT "\n";
	}
	close OUT or die "$file: $!";
}

sub readlines {
	my $file = shift @_;
	open( IN, "<", $file ) or die "cannot open $file: $!";
	my @lines = (<IN>);
	close IN or die "cannot close $file: $!";
	return @lines;
}

sub writelines {
	my ( $file, @lines ) = @_;
	open( OUT, ">", $file );
	print OUT @lines;
	close OUT or die "cannot close $file: $!";
}

sub readfiles {
	my $dir = shift @_;
	opendir( DIR, $dir ) or die "can't open dir $dir: $!";
	my @files = readdir DIR;
	close DIR;
	return @files;
}

sub hashify {
	my $file = shift @_;
	my $key  = shift @_ || 'eo';
	my $obj  = Text::CSV::Hashify->new(
		{
			file   => $file,
			format => 'hoh',
			key    => $key,
		}
	);
	my $hash_ref = $obj->all;
	return $hash_ref;
}

sub sbh {
	my $dbh = DBI->connect("dbi:CSV:")
	  or die "Cannot connect: $DBI::errstr";

	# Simple statements
	$dbh->do("CREATE TABLE a (id INTEGER, name CHAR (10))")
	  or die "Cannot prepare: " . $dbh->errstr();

	# Selecting
	$dbh->{RaiseError} = 1;
	my $sth = $dbh->prepare("select * from foo");
	$sth->execute;
	while ( my @row = $sth->fetchrow_array ) {
		print "id: $row[0], name: $row[1]\n";
	}

	# Updates
	my $sth = $dbh->prepare("UPDATE a SET name = ? WHERE id = ?");
	$sth->execute( "DBI rocks!", 1 );
	$sth->finish;

	$dbh->disconnect;
}
1;
