
package File::Slurp;

# Copyright (C) 1994-1996, 1998, 2001-2002  David Muir Sharnoff

require Exporter;
@ISA = qw(Exporter);
@EXPORT = qw(read_file write_file overwrite_file append_file read_dir);

use Carp;

use vars qw($VERSION);
$VERSION = 2002.1031;

sub read_file
{
	my ($file) = @_;

	local($/) = wantarray ? $/ : undef;
	local(*F);
	my $r;
	my (@r);

	open(F, "<$file") || croak "open $file: $!";
	@r = <F>;
	close(F) || croak "close $file: $!";

	return $r[0] unless wantarray;
	return @r;
}

sub write_file
{
	my ($f, @data) = @_;

	local(*F);

	open(F, ">$f") || croak "open >$f: $!";
	(print F @data) || croak "write $f: $!";
	close(F) || croak "close $f: $!";
	return 1;
}

sub overwrite_file
{
	my ($f, @data) = @_;

	local(*F);

	if (-e $f) {
		open(F, "+<$f") || croak "open +<$f: $!";
	} else {
		open(F, "+>$f") || croak "open >$f: $!";
	}
	(print F @data) || croak "write $f: $!";
	my $where = tell(F);
	croak "could not tell($f): $!"
		unless defined $where;
	truncate(F, $where)
		|| croak "trucate $f at $where: $!";
	close(F) || croak "close $f: $!";
	return 1;
}

sub append_file
{
	my ($f, @data) = @_;

	local(*F);

	open(F, ">>$f") || croak "open >>$f: $!";
	(print F @data) || croak "write $f: $!";
	close(F) || croak "close $f: $!";
	return 1;
}

sub read_dir
{
	my ($d) = @_;

	my (@r);
	local(*D);

	opendir(D,$d) || croak "opendir $d: $!";
	@r = grep($_ ne "." && $_ ne "..", readdir(D));
	closedir(D) || croak "closedir $d: $!";
	return @r;
}

1;

__END__

=head1 NAME

	File::Slurp -- single call read & write file routines; read directories

=head1 SYNOPSIS

	use File::Slurp;

	$all_of_it = read_file($filename);
	@all_lines = read_file($filename);

	write_file($filename, @contents)

	overwrite_file($filename, @new_contnts);

	append_file($filename, @additional_contents);

	@files = read_dir($directory);

=head1 DESCRIPTION

These are quickie routines that are meant to save a couple of lines of
code over and over again.  They do not do anything fancy.
 
read_file() does what you would expect.  If you are using its output
in array context, then it returns an array of lines.  If you are calling
it from scalar context, then returns the entire file in a single string.

It croaks()s if it can't open the file.

write_file() creates or overwrites files.

append_file() appends to a file.

overwrite_file() does an in-place update of an existing file or creates
a new file if it didn't already exist.  Write_file will also replace a
file.  The difference is that the first that that write_file() does is 
to trucate the file whereas the last thing that overwrite_file() is to
trucate the file.  Overwrite_file() should be used in situations where
you have a file that always needs to have contents, even in the middle
of an update.

read_dir() returns all of the entries in a directory except for "."
and "..".  It croaks if it cannot open the directory.

=head1 LICENSE

Copyright (C) 1996, 1998, 2001 David Muir Sharnoff.  License hereby
granted for anyone to use, modify or redistribute this module at 
their own risk.  Please feed useful changes back to muir@idiom.com.

=head1 AUTHOR

David Muir Sharnoff <muir@idiom.com>

