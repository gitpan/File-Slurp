
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

__END__

=head2 B<prepend_file>

This sub writes data to the beginning of a file. The previously
existing data is written after that so the effect is prepending data
in front of a file. It is a counterpart to the append_file sub in this
module.

  use File::Slurp qw( prepend_file ) ;
  prepend_file( 'filename', @data ) ;

The first argument to C<prepend_file> is the filename. The next argument
is an optional hash reference and it contains key/values that can
modify the behavior of C<prepend_file>. The rest of the argument list is
the data to be written to the file.

  prepend_file( 'filename', {binmode => ':raw'}, $buffer ) ;

C<prepend_file> works by calling C<read_file> and then C<write_file>
with the new data and the existing data just read in. Read the
documentation for those calls for details not covered here.

The options are:

=head3 binmode

If you set the binmode option, then its value is passed to a call to
binmode on the opened handle. You can use this to set the file to be
read in binary mode, utf8, etc. See perldoc -f binmode for more.

	prepend_file( $bin_file, {binmode => ':raw'}, @data ) ;
	prepend_file( $bin_file, {binmode => ':utf8'}, $utf_text ) ;

=head3 err_mode

You can use this option to control how C<prepend_file> behaves when an
error occurs. See the documentation in C<read_file> and C<write_file>
for more on this.

=head3 atomic mode is always enabled

In the internal call to C<write_file>, the C<atomic> flag is always
set which means you will always have a stable file, either the old one
or the complete new one. See the C<atomic> option in C<write_file> for
more on this.
