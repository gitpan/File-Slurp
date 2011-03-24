##!/usr/local/bin/perl -w

use lib qw(t) ;
use strict ;
use Test::More ;

BEGIN {
	plan skip_all => "these tests need Perl 5.5" if $] < 5.005 ;
}

use TestDriver ;
use File::Slurp qw( :all ) ;

my $is_win32 = $^O =~ /cygwin|win32/i ;

my $file_name = 'test_file' ;
my $dir_name = 'test_dir' ;

my $tests = [
	{
		name	=> 'read_file open error',
		sub	=> \&read_file,
		args	=> [ $file_name ],
		error	=> qr/open/,
	},
	{
		name	=> 'write_file open error',
		sub	=> \&write_file,
 		args	=> [ $file_name, '' ],
 		override => 'sysopen',
		error	=> qr/open/,
	},
	{
		name	=> 'write_file syswrite error',
		sub	=> \&write_file,
		args	=> [ $file_name, '' ],
		override => 'syswrite',
		posttest => sub { unlink( $file_name ) },
		error	=> qr/write/,
	},
	{
		name	=> 'read_file small sysread error',
		sub	=> \&read_file,
		args	=> [ $file_name ],
		override => 'sysread',
		pretest => sub { write_file( $file_name, '' ) },
		posttest => sub { unlink( $file_name ) },
		error	=> qr/read/,
	},
	{
		name	=> 'read_file loop sysread error',
		sub	=> \&read_file,
		args	=> [ $file_name ],
		override => 'sysread',
		pretest => sub { write_file( $file_name, 'x' x 100_000 ) },
		posttest => sub { unlink( $file_name ) },
		error	=> qr/read/,
	},
	{
		name	=> 'atomic rename error',
# this test is meaningless on Win32
		skip	=> $is_win32,
		sub	=> \&write_file,
		args	=> [ $file_name, { atomic => 1 }, '' ],
		override => 'rename',
		posttest => sub { unlink( $file_name, "$file_name.$$" ) },
		error	=> qr/rename/,
	},
	{
		name	=> 'read_dir opendir error',
		sub	=> \&read_dir,
		args	=> [ $dir_name ],
		error	=> qr/open/,
	},
] ;

test_driver( $tests ) ;

exit ;

