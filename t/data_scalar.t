#!/usr/local/bin/perl -w

use strict ;

use Carp ;
use Fcntl qw( :seek ) ;
use Test::More tests => 2 ;

BEGIN{ 
	use_ok( 'File::Slurp', ) ;
}

test_data_scalar_slurp() ;

exit ;

sub test_data_scalar_slurp {

	my $data_seek = tell( \*DATA );

# first slurp in the text
 
	my $slurp_text = read_file( \*DATA ) ;

# now we need to get the golden data

	seek( \*DATA, $data_seek, SEEK_SET ) || die "seek $!" ;
	my $data_text = join( '', <DATA> ) ;

	is( $slurp_text, $data_text, 'scalar slurp of DATA' ) ;
}

__DATA__
line one
second line
more lines
still more

enough lines

we can't test long handle slurps from DATA since i would have to type
too much stuff

so we will stop here
