#!/usr/local/bin/perl -w

use strict ;

use Carp ;
use Fcntl qw( :seek ) ;
use Test::More tests => 2 ;

BEGIN{ 
	use_ok( 'File::Slurp', ) ;
}

test_data_list_slurp() ;

exit ;


sub test_data_list_slurp {

	my $data_seek = tell( \*DATA );

# first slurp in the lines
 
	my @slurp_lines = read_file( \*DATA ) ;

# now seek back and read all the lines with the <> op and we make
# golden data sets

	seek( \*DATA, $data_seek, SEEK_SET ) || die "seek $!" ;
	my @data_lines = <DATA> ;

# test the array slurp

	ok( eq_array( \@data_lines, \@slurp_lines ), 'list slurp of DATA' ) ;
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
