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
skip => 1,
		name	=> 'read_file open error',
		sub	=> \&read_file,
		args	=> [ $file_name ],

		error => qr/open/,
	},

	{
skip => 1,
		name	=> 'write_file open error',
		sub	=> \&write_file,
		args	=> [ "$dir_name/$file_name", '' ],
		pretest => sub {
			mkdir $dir_name, 0550 ;
			chmod( 0555, $dir_name ) ;
		},

		posttest => sub {

			chmod( 0777, $dir_name ) ;
			rmdir $dir_name ;
		},

		error => qr/open/,
	},

	{
skip => 1,
		name	=> 'write_file syswrite error',
		sub	=> \&write_file,
		args	=> [ $file_name, '' ],
		override	=> 'syswrite',

		posttest => sub {
			unlink( $file_name ) ;
		},


		error => qr/write/,
	},

	{
skip => 1,
		name	=> 'read_file small sysread error',
		sub	=> \&read_file,
		args	=> [ $file_name ],
		override	=> 'sysread',

		pretest => sub {
			write_file( $file_name, '' ) ;
		},

		posttest => sub {
			unlink( $file_name ) ;
		},


		error => qr/read/,
	},

	{
skip => 1,
		name	=> 'read_file loop sysread error',
		sub	=> \&read_file,
		args	=> [ $file_name ],
		override	=> 'sysread',

		pretest => sub {
			write_file( $file_name, 'x' x 100_000 ) ;
		},

		posttest => sub {
			unlink( $file_name ) ;
		},


		error => qr/read/,
	},

	{
		name	=> 'atomic rename error',
		skip	=> $is_win32,		# meaningless on Win32
		sub	=> \&write_file,
		args	=> [ "$dir_name/$file_name", { atomic => 1 }, '' ],
		pretest => sub {
			mkdir $dir_name, 0700 ;
			write_file( "$dir_name/$file_name.$$", '' ) ;
			chmod( 0555, $dir_name ) ;
		},

		posttest => sub {

			chmod( 0777, $dir_name ) ;
			unlink( "$dir_name/$file_name.$$" ) ;
			rmdir $dir_name ;
		},

		error => qr/rename/,
	},

	{
skip => 1,
		name	=> 'read_dir opendir error',
		sub	=> \&read_dir,
		args	=> [ $dir_name ],

		error => qr/open/,
	},
] ;

test_driver( $tests ) ;

exit ;

