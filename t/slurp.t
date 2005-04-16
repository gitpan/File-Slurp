#!/usr/local/bin/perl -w

use strict ;

use Carp ;
use Fcntl qw( :seek ) ;
use Socket ;
use Symbol ;
use Test::More tests => 2 ;

BEGIN{ 
	use_ok( 'File::Slurp', qw( write_file slurp ) ) ;
}

my $data = <<TEXT ;
line 1
more text
TEXT

foreach my $file ( qw( xxx ) ) {

	write_file( $file, $data ) ;
	my $read_buf = slurp( $file ) ;
	is( $read_buf, $data, 'slurp alias' ) ;

	unlink $file ;
}
