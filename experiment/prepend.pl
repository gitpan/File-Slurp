
use strict ;
use warnings ;

use lib '../blib' ;
use lib '../t' ;

use File::Slurp ;
use Test::More ;

use TestDriver ;

my $file = 'prepend_file' ;
my $existing_data = <<PRE ;
line 1
line 2
more
PRE


sub prepend_file {

	my $file_name = shift ;

#print "FILE $file_name\n" ;
	my $opts = ( ref $_[0] eq 'HASH' ) ? shift : {} ;

	my $prepend_data = shift ;
	$prepend_data = '' unless defined $prepend_data ;
	$prepend_data = ${$prepend_data} if ref $prepend_data eq 'SCALAR' ;

#print "PRE [$prepend_data]\n" ;

	$opts->{ scalar_ref } = 1 ;

	my $existing_data = read_file( $file_name, %{$opts} ) ;

#print "EXIST [$$existing_data]\n" ;

	$opts->{ atomic } = 1 ;

	return write_file( $file_name, $opts,
			   $prepend_data, $$existing_data
	) ;
}

my $tests = [
	{
		name	=> 'prepend null',
		sub	=> \&prepend_file,
		prepend_data	=> '',
		pretest	=> sub {
			my( $test ) = @_ ;
			write_file( $file, $existing_data ) ;
			my $prepend_data = $test->{prepend_data} ;
			$test->{args} = [
				$file,
				$prepend_data,
			] ;
			$test->{expected} = "$prepend_data$existing_data" ;
		},
		posttest => sub { $_[0]->{result} = read_file( $file ) },
	},
	{
		name	=> 'prepend line',
		sub	=> \&prepend_file,
		prepend_data => "line 0\n",
		pretest	=> sub {
			my( $test ) = @_ ;
			write_file( $file, $existing_data ) ;
			my $prepend_data = $test->{prepend_data} ;
			$test->{args} = [
				$file,
				$prepend_data,
			] ;
			$test->{expected} = "$prepend_data$existing_data" ;
		},
		posttest => sub { $_[0]->{result} = read_file( $file ) },
	},
	{
		name	=> 'prepend partial line',
		sub	=> \&prepend_file,
		prepend_data => 'partial line',
		pretest	=> sub {
			my( $test ) = @_ ;
			write_file( $file, $existing_data ) ;
			my $prepend_data = $test->{prepend_data} ;
			$test->{args} = [
				$file,
				$prepend_data,
			] ;
			$test->{expected} = "$prepend_data$existing_data" ;
		},
		posttest => sub { $_[0]->{result} = read_file( $file ) },
	},
] ;

test_driver( $tests ) ;

unlink $file ;

exit ;
