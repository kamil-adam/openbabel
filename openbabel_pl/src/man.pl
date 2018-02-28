#!/usr/bin/perl 
#-W
use Acme::Import;
use Acme::Tr;
use Acme::Heap;

use Log::Log4perl qw(:easy);
Log::Log4perl->easy_init($DEBUG);
my $logger = Log::Log4perl->get_logger('pl.writeonly.perl.man');

# ścieżka do folderu z plikem
my $TEXT_CSV_MAN = '../text/csv/man';

my $N = 1;

sub def {
	my $hash = shift @_;
	$hash{$lang} = $hash{$lang_pos} - $hash{$lang_neg};
	$hash;
}

sub hash_print {
	my $hash    = shift @_;
	my $builder = "";
	foreach $key ( keys %$hash ) {
		my $value = $hash->{$key};
		$builder .= "|$key| => |$value|, ";
	}
	$builder;
}

sub array_foreach {
	my $array_ref = shift @_;
	my $lang_pos  = shift @_;
	my $lang_neg  = shift @_;

	foreach my $hash (@$array_ref) {
		$logger->debug( "man, hash => " . $hash );

#$hash{$lang_pos} = 0 if ( $hash{$lang_pos} eq '' or $hash{$lang_pos} eq undef );
#$hash{$lang_neg} = 0 if ( $hash{$lang_neg} eq '' or $hash{$lang_pos} eq undef );
		if ( $hash{$lang_pos} eq '' or $hash{$lang_pos} eq undef ) {
			$logger->debug("man, lang_pos => $lang_pos");
			$hash{$lang_pos} = 0;
		}
		else {
			#$logger->debug("man, hash {lang_pos}=> ".$hash{$lang_pos});
		}
		if ( $hash{$lang_neg} eq '' or $hash{$lang_pos} eq undef ) {
			$logger->debug("man, lang_neg => $lang_neg");
			$hash{$lang_neg} = 0;
		}
		else {
			#$logger->debug("man, hash {lang_neg}=> ".$hash{$lang_neg});
		}
		def $hash;
	}
}

sub array_for {
	my $array_ref = shift @_;
	my $lang_pos  = shift @_;
	my $lang_neg  = shift @_;
	for ( my $i = 0 ; $i < @$array_ref ; ++$i ) {
		my $hash = $array_ref->[$i];
		$logger->debug( "man, hash => " . $hash );

#$hash{$lang_pos} = 0 if ( $hash{$lang_pos} eq '' or $hash{$lang_pos} eq undef );
#$hash{$lang_neg} = 0 if ( $hash{$lang_neg} eq '' or $hash{$lang_pos} eq undef );
		if (   $array_ref->[$i]{$lang_pos} eq ''
			or $array_ref->[$i]{$lang_pos} eq undef )
		{
			$logger->debug("man, lang_pos => $lang_pos");
			$array_ref->[$i]{$lang_pos} = 0;
		}
		else {
			#$logger->debug("man, hash {lang_pos}=> ".$hash{$lang_pos});
		}
		if (   $array_ref->[$i]{$lang_neg} eq ''
			or $array_ref->[$i]{$lang_pos} eq undef )
		{
			$logger->debug("man, lang_neg => $lang_neg");
			$array_ref->[$i]{$lang_neg} = 0;
		}
		else {
			#$logger->debug("man, hash {lang_neg}=> ".$hash{$lang_neg});
		}
		#$array_ref->[$i] = def $array_ref->[$i];
		#$array_ref->[$i] = $array_ref->[$i]{$lang_pos} - $array_ref->[$i]{$lang_neg};
	}
}

sub run {
	my $file      = shift @_;
	my $lang_from = shift @_;
	my $lang_to   = shift @_;
	my $lang      = $lang_from . '.' . $lang_to;
	my $lang_pos  = $lang . '.pos';
	my $lang_neg  = $lang . '.neg';
	my $array_ref = Text::CSV::Hashify->new(
		{
			file   => $file,
			format => 'aoh',
		}
	)->all;
	$logger->debug( "man, size => " . @$array_ref );
	$logger->debug( "man, array_ref => " . $array_ref );

	#array_foreach( $array_ref, $lang_pos, $lang_neg );
	array_for( $array_ref, $lang_pos, $lang_neg );

	#exit;
	my $cb = sub {
		my $hash = shift @_;
		$hash or die "hash";
		$logger->debug( "hash_print" . hash_print($hash) );
		my $result = $hash{$lang};
		$logger->debug( "lang " . $lang );
		$logger->debug( "result " . $result );
		$result;
	};

	my $heap = Acme::Heap->new( { 'cb' => $cb, 'array' => $array_ref } );
	$heap->build_heap;

	#do {
	my $top  = $heap{'array'}[0];
	my @tops = $heap->tops($N);

	@tops = List::Util::shuffle @tops;
	for ( my $i = 0 ; $i < $N ; $i += 1 ) {
		print("$i. $tops[$i]\n");
	}
	my $c = getc;
	if ( $tops[$c] == $top ) {
		$top{$lang_pos} += 1;
		def $top;
	}
	else {
		$top{$lang_neg} += 1;
		def $top;
		$tops[$c]{$lang_neg} += 1;
		def $tops[$c]{$lang_neg};
	}
	$heap->heapify(0);

	#} until (0);
}

sub main {
	run "$TEXT_CSV_MAN/vortoj.csv", 'pl', 'de';
}

main;

__END__

=begin
skrypt działający na pojedynczym arkuszu jako bazie danych 
=end

