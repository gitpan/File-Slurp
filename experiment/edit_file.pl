
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

__END__

=head2 B<edit_file>

This sub writes out an entire file in one call.

  write_file( 'filename', @data ) ;

The first argument to C<write_file> is the filename. The next argument
is an optional hash reference and it contains key/values that can
modify the behavior of C<write_file>. The rest of the argument list is
the data to be written to the file.

  write_file( 'filename', {append => 1 }, @data ) ;
  write_file( 'filename', {binmode => ':raw'}, $buffer ) ;

As a shortcut if the first data argument is a scalar or array reference,
it is used as the only data to be written to the file. Any following
arguments in @_ are ignored. This is a faster way to pass in the output
to be written to the file and is equivalent to the C<buf_ref> option of
C<read_file>. These following pairs are equivalent but the pass by
reference call will be faster in most cases (especially with larger
files).

  write_file( 'filename', \$buffer ) ;
  write_file( 'filename', $buffer ) ;

  write_file( 'filename', \@lines ) ;
  write_file( 'filename', @lines ) ;

If the first argument is a handle (if it is a ref and is an IO or GLOB
object), then that handle is written to. This mode is supported so you
spew to handles such as \*STDOUT. See the test handle.t for an example
that does C<open( '-|' )> and child process spews data to the parent
which slurps it in.  All of the options that control how the data are
passed into C<write_file> still work in this case.

If the first argument is an overloaded object then its stringified value
is used for the filename and that file is opened.  This is new feature
in 9999.14. See the stringify.t test for an example.

By default C<write_file> returns 1 upon successfully writing the file or
undef if it encountered an error. You can change how errors are handled
with the C<err_mode> option.

The options are:

=head3 binmode

If you set the binmode option, then its value is passed to a call to
binmode on the opened handle. You can use this to set the file to be
read in binary mode, utf8, etc. See perldoc -f binmode for more.

	write_file( $bin_file, {binmode => ':raw'}, @data ) ;
	write_file( $bin_file, {binmode => ':utf8'}, $utf_text ) ;

=head3 perms

The perms option sets the permissions of newly-created files. This value
is modified by your process's umask and defaults to 0666 (same as
sysopen).

NOTE: this option is new as of File::Slurp version 9999.14;

