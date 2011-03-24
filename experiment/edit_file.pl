
use strict ;
use warnings ;

use lib '../blib' ;
use lib '../t' ;

use File::Slurp ;
use Test::More ;

use TestDriver ;

my $file = 'edit_file' ;
my $existing_data = <<PRE ;
line 1
line 2
more
PRE


sub edit_file(&$;$) {

	my $edit_code = shift ;
	my $file_name = shift ;

#print "FILE $file_name\n" ;
	my $opts = ( ref $_[0] eq 'HASH' ) ? shift : {} ;

	$opts->{ scalar_ref } = 1 ;

	my $existing_data = read_file( $file_name, %{$opts} ) ;

#print "EXIST [$$existing_data]\n" ;

	$opts->{ atomic } = 1 ;

	my( $edited_data ) = map { $edit_code->(); $_ } $$existing_data ;

	return write_file( $file_name, $opts, $edited_data ) ;
}

my $tests = [
	{
		name	=> 'no edit 0',
		sub	=> \&edit_file,
		code	=> sub {},
		pretest	=> sub {
			my( $test ) = @_ ;
			write_file( $file, $existing_data ) ;
			$test->{args} = [
				$test->{code},
				$file
			] ;
			( $test->{expected} ) =
				map { $test->{code}() ; $_ } $existing_data ;
		},
		posttest => sub { $_[0]->{result} = read_file( $file ) },
	},
	{
		name	=> 'change edit',
		sub	=> \&edit_file,
		code	=> sub { s/line/foo/g },
		pretest	=> sub {
			my( $test ) = @_ ;
			write_file( $file, $existing_data ) ;
			$test->{args} = [
				$test->{code},
				$file
			] ;
			( $test->{expected} ) =
				map { $test->{code}() ; $_ } $existing_data ;
		},
		posttest => sub { $_[0]->{result} = read_file( $file ) },
	},
	{
		name	=> 'change edit',
		sub	=> \&edit_file,
		code	=> sub { s/^.+2$//m },
		pretest	=> sub {
			my( $test ) = @_ ;
			write_file( $file, $existing_data ) ;
			$test->{args} = [
				$test->{code},
				$file
			] ;
			( $test->{expected} ) =
				map { $test->{code}() ; $_ } $existing_data ;
		},
		posttest => sub { $_[0]->{result} = read_file( $file ) },
	},
	{
		name	=> 'delete all',
		sub	=> \&edit_file,
		code	=> sub { $_ = '' },
		pretest	=> sub {
			my( $test ) = @_ ;
			write_file( $file, $existing_data ) ;
			$test->{args} = [
				$test->{code},
				$file
			] ;
			( $test->{expected} ) =
				map { $test->{code}() ; $_ } $existing_data ;
		},
		posttest => sub { $_[0]->{result} = read_file( $file ) },
	},
	{
		name	=> 'utf8',
		sub	=> \&edit_file,
		code	=> sub { s/abc// },
		pretest	=> sub {
			my( $test ) = @_ ;

			my $orig_text = "abc\x{20ac}\n" ;
			$orig_text =~ s/\n/\015\012/ if $^O =~ /win32/i ;
			write_file( $file, {binmode => ':utf8'}, $orig_text ) ;
			$test->{args} = [
				$test->{code},
				$file,
				{ binmode => ':utf8' },
			] ;
			( $test->{expected} ) =
				map { $test->{code}() ; $_ } $orig_text ;
		},
		posttest => sub { $_[0]->{result} =
			read_file( $file, binmode => ':utf8' )
		},
	},
] ;

test_driver( $tests ) ;

unlink $file ;

exit ;
