#!/usr/bin/perl 
#-W
use Acme::Import;
use Acme::Tr;
use Acme::Heap;

# nieobrobione dane z lernu
my $TEXT_LERNU = '../text/lernu';

# scalone dane według języków
my $TEXT_CSV_LANG = '../text/csv/lang';

#obrobione dane z lernu
my $TEXT_CSV_LERNU = '../text/csvlernu';

# ręcznie przygotowane dane do scalenia
my $TEXT_CSV_MAN = '../text/csv/man';

# inne dane nie nadające się do scalenia
my $TEXT_CSV_OTHER = '../text/csv/other';

# pliki csv wygenerowane z plików innych plików
my $TEXT_CSV_PKG = '../text/csv/pkg';

# raporty wygenerowane z kopcowania
my $TEXT_CSV_REPORT = '../text/csv/report';

# folder na tabele
my $TEXT_CSV_TABLE = '../text/csv/table';

# tymczasowy okrojony folder lang do generacji raportów specjalnych
my $TEXT_CSV_TEMP = '../text/csv/temp';

####testy

sub test_lernu2csv {
	$logger->debug('test_lernu2csv');
	Acme::Import::lernu2csv $TEXT_LERNU, $TEXT_CSV_PKG;
}

sub test_parse_man_csv {
	$logger->debug('test_parse_man_csv');
	Tr::parse_man_csv( $TEXT_CSV_MAN, $TEXT_CSV_PKG, '', 'de', 'en', 'pl' );
}

sub test_scal_csv {
	$logger->debug('test_scal_csv');
	Tr::scal_csv( $TEXT_CSV_PKG, $TEXT_CSV_LANG, 'de' );
	Tr::scal_csv( $TEXT_CSV_PKG, $TEXT_CSV_LANG, 'en' );
	Tr::scal_csv( $TEXT_CSV_PKG, $TEXT_CSV_LANG, 'pl' );
}

sub test_report_generate {
	$logger->debug('test_generate_raport');
	report_generate(
		$TEXT_CSV_LANG,
		$TEXT_CSV_REPORT . 'report.csv',
		( 'de', 'en', 'pl' )
	);
}

#main;

sub test_data2raport {
	test_lernu2csv();
	test_parse_man_csv();
	test_scal_csv();
	test_report_generate();
}

sub test_temp2raport {

	my $lernu = 'ligvortoj|ne-e-adverboj|prepozicioj';

	#my $lernu = 'ne-e-adverboj';

	my $man = 'verboj';
	my $pkg = $lernu . '|' . $man;

	#my $pkg = $lernu;
	Acme::Import::lernu2csv( $TEXT_LERNU, $TEXT_CSV_PKG, $lernu );
	Acme::Tr::parse_man_csv( $TEXT_CSV_MAN, $TEXT_CSV_PKG, $pkg,
		( 'de', 'en', 'pl' ) );
	Acme::Tr::scal_csv( $TEXT_CSV_PKG, $TEXT_CSV_TEMP, $pkg, 'de' );
	Acme::Tr::scal_csv( $TEXT_CSV_PKG, $TEXT_CSV_TEMP, $pkg, 'en' );
	Acme::Tr::scal_csv( $TEXT_CSV_PKG, $TEXT_CSV_TEMP, $pkg, 'pl' );
	Acme::Tr::report_generate( $TEXT_CSV_TEMP, $TEXT_CSV_REPORT . 'temp.csv',
		0, ( 'de', 'en', 'pl' ) );
}

sub test_hashify {

	my $hash_ref =
	  Acme::CSVFacade::hashify( $TEXT_CSV_LANG . '/en.csv', 'eo' )
}

#test_temp2raport();
test_hashify;
