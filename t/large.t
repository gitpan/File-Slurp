#!/usr/local/bin/perl -w

use strict ;

use Test::More ;
use Carp ;

BEGIN{ 
	use_ok( 'File::Slurp', ) ;
}

my $file = 'slurp.data' ;
unlink $file ;

my @text_data = (
	'',
	'a' x 8,
	"\n" x 100,
	join( "\n", ('a' x 8) x 3 ),
	join( "\n", ('a' x 100) x 1024 ),
	join( "\n", ('a' x 1024) x 1024 ),
	'',
) ;

my @bin_sizes = ( 1000, 1024 * 1024 ) ;

my @bin_stuff = ( "\012", "\015", "\012\015", "\015\012",
		map chr, 0 .. 32 ) ;

my @bin_data ;

foreach my $size ( @bin_sizes ) {

	my $data = '' ;

	while ( length( $data ) < $size ) {

		$data .= $bin_stuff[ rand @bin_stuff ] ;
	}

	push @bin_data, $data ;
}

plan( tests => 16 * @text_data + 8 * @bin_data ) ;

#print "# text slurp\n" ;

foreach my $data ( @text_data ) {

	test_text_slurp( $data ) ;
}

#print "# BIN slurp\n" ;

foreach my $data ( @bin_data ) {

	test_bin_slurp( $data ) ;
}

unlink $file ;

exit ;

sub test_text_slurp {

	my( $data ) = @_ ;

	my $err = write_file( $file, $data ) ;
	ok( $err, 'write_file - ' . length $data ) ;
	my $text = read_file( $file ) ;
	ok( $text eq $data, 'scalar read_file - ' . length $data ) ;

	$err = write_file( $file, \$data ) ;
	ok( $err, 'write_file ref arg - ' . length $data ) ;
	$text = read_file( $file ) ;
	ok( $text eq $data, 'scalar read_file - ' . length $data ) ;

	$err = write_file( $file, { buf_ref => \$data } ) ;
	ok( $err, 'write_file buf ref opt - ' . length $data ) ;
	$text = read_file( $file ) ;
	ok( $text eq $data, 'scalar read_file - ' . length $data ) ;

	my $text_ref = read_file( $file, scalar_ref => 1 ) ;
	ok( ${$text_ref} eq $data, 'scalar ref read_file - ' . length $data ) ;

	read_file( $file, buf_ref => \my $buffer ) ;
	ok( $buffer eq $data, 'buf_ref read_file - ' . length $data ) ;

	my @data_lines = split( m|(?<=$/)|, $data ) ;

	$err = write_file( $file, \@data_lines ) ;
	ok( $err, 'write_file list ref arg - ' . length $data ) ;
	$text = read_file( $file ) ;
	ok( $text eq $data, 'scalar read_file - ' . length $data ) ;

#print map "[$_]\n", @data_lines ;
#print "DATA <@data_lines>\n" ;

	my @array = read_file( $file ) ;

#print map "{$_}\n", @array ;
#print "ARRAY <@array>\n" ;

	ok( eq_array( \@array, \@data_lines ),
			'array read_file - ' . length $data ) ;

 	my $array_ref = read_file( $file, array_ref => 1 ) ;
	ok( eq_array( $array_ref, \@data_lines ),
 			'array ref read_file - ' . length $data ) ;

	$err = write_file( $file, { append => 1 }, $data ) ;
	ok( $err, 'write_file append - ' . length $data ) ;

	my $text2 = read_file( $file ) ;
	ok( $text2 eq $data x 2, 'read_file append - ' . length $data ) ;

	$err = append_file( $file, $data ) ;
	ok( $err, 'append_file - ' . length $data ) ;

	my $bin3 = read_file( $file ) ;
	ok( $bin3 eq $data x 3, 'read_file append_file - ' . length $data ) ;

	return ;
}

sub test_bin_slurp {

	my( $data ) = @_ ;

	my $err = write_file( $file, {binmode => ':raw'}, $data ) ;
	ok( $err, 'write_file bin - ' . length $data ) ;

	my $bin = read_file( $file, binmode => ':raw' ) ;
	ok( $bin eq $data, 'scalar read_file bin - ' . length $data ) ;

	my $bin_ref = read_file( $file, scalar_ref => 1, binmode => ':raw' ) ;
	ok( ${$bin_ref} eq $data,
			'scalar ref read_file bin - ' . length $data ) ;

	read_file( $file, buf_ref => \(my $buffer), binmode => ':raw'  ) ;
	ok( $buffer eq $data, 'buf_ref read_file bin - ' . length $data ) ;

	$err = write_file( $file, { append => 1, binmode => ':raw' }, $data ) ;
	ok( $err, 'write_file append bin - ' . length $data ) ;

	my $bin2 = read_file( $file, binmode => ':raw' ) ;
	ok( $bin2 eq $data x 2, 'read_file append bin - ' . length $data ) ;

	$err = append_file( $file, { binmode => ':raw' }, $data ) ;
	ok( $err, 'append_file - bin  ' . length $data ) ;

	my $bin3 = read_file( $file, binmode => ':raw' ) ;
	ok( $bin3 eq $data x 3, 'read_file bin - ' . length $data ) ;

	return ;
}
