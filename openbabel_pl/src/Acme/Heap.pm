package Acme::Heap;

#use AutoLoader;
use Carp;
use Switch;
use Spiffy qw( -Base );
use strict;

use Log::Log4perl qw(:easy);
Log::Log4perl->easy_init($DEBUG);
my $logger = Log::Log4perl->get_logger('pl.writeonly.perl.Heap');

#use Log::Log4perl qw(:easy);
#Log::Log4perl->easy_init($DEBUG);
#my $logger = Log::Log4perl->get_logger('Acme::Heap');

field 'array';
field 'cb';

sub new {
	my $obj = shift @_;
	bless $obj;
}

sub build_heap {
	for ( my $i = 0 ; $i < @$self{'array'} ; $i += 1 ) {
		$self->heapify($i);
	}
}

sub heapify {
	my $a       = shift @_;
	my $largest = $a;
	my $a2      = $a * 2;
	my $size    = $self->array;

	my $cb_a2      = $self->cb( $self->array()->[$a2] );
	my $cb_a2_1    = $self->cb( $self->array()->[ $a2 + 1 ] );
	my $cb_largest = $self->cb( $self->array()->[$largest] );
	$logger->debug("cb_a2 $cb_a2");
	$logger->debug("cb_a2_1 $cb_a2_1");
	$logger->debug("cb_largest $cb_largest");

	if (   $a2 <= $size
		&& $self->cb( $self->array()->[$a2] ) >
		$self->cb( $self->array()->[$largest] ) )
	{
		$largest = $a2;
	}
	if (   $a2 + 1 <= $size
		&& $self->cb( $self->array()->[ $a2 + 1 ] ) >
		$self->cb( $self->array()->[$largest] ) )
	{
		$largest = $a2 + 1;
	}
	if ( $largest != $a ) {
		$self->swap( $a, $largest );
		$self->heapify($largest);
	}
}

sub swap {
	my $a = shift @_;
	my $b = shift @_;
	$logger->debug(" a $a");
	my $t = $self->{'array'}->[$a];
	$self->{'array'}[$a] = $self->{'array'}[$b];
	$self->{'array'}[$b] = $t;
}

#kopcuje ;)
sub init {
	my $file = shift @_;
	open( FILE, " < ", $file ) or die " cannot open < $file : $! ";
	my @lines = (<FILE>);
	my @rows  = to_csv(@lines);
	$self->array( \@rows );
	build_heap();
	my $size = @$self->array;
	my $c;
	do {

		for ( my $i = 0 ; $i < $self->N and $i < $size ; $i += 1 ) {

			#print
		}
		$c = getc;
	} until ( $c eq '0' );
}

sub tops {
	my $n     = shift @_;
	my @array = ();
	for ( my $i = 0 ; $i < $n ; ++$i ) {
		push @array, $self->{'array'}[$i];
	}
	@array;
}

#sub array {
#	$self->{'array'};
#}

sub cb {
	my $result = $self->{'cb'}(@_);
	$logger->debug("result $result");
	$result;
}

__END__

sub AUTOLOAD {
	my $sub = $AUTOLOAD;
	( my $constname = $sub ) =~ s/.*:://;
	my $val = constant( $constname, @_ ? $_[0] : 0 );
	if ( $! != 0 ) {
		if ( $! =~ /Invalid/ || $!{EINVAL} ) {
			$AutoLoader::AUTOLOAD = $sub;
			goto &AutoLoader::AUTOLOAD;
		}
		else {
			croak " Your vendor has not defined constant $constname";
		}
	}
	*$sub = sub { $val };    # same as: eval " sub $sub{$val} ";
	goto &$sub;
}
1;

Skrypt odpowiedzialny za kopcowanie tablicy
