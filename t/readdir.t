#!/usr/local/bin/perl

$tmp = "/tmp/rdt$$";

BEGIN { unshift(@INC, "."); }
use File::Slurp;

print "1..4\n";

mkdir($tmp, 0700) || die "mkdir $tmp: $!";

@y = read_dir($tmp);

if (@y == 0) {print "ok 1\n";} else {print "not ok 1\n"}

&write_file("$tmp/x", "foo\n");

@y = read_dir($tmp);

if (@y == 1) {print "ok 2\n";} else {print "not ok 2\n"}
if ($y[0] eq 'x') {print "ok 3\n";} else {print "not ok 3\n"}

@x = sort ( 'x', 1..23 );

for $x (@x) {
	&write_file("$tmp/$x", "foo\n");
}

if ($] > 5.002) {
	@y = sort read_dir($tmp);
} else {
	# bug in 5.002
	@y = read_dir($tmp);
	@y = sort @y;
}

while (@x && @y) {
	last unless $x[0] eq $y[0];
	shift @x;
	shift @y;
}

if (@x == @y) { print "ok 4\n";} else {print "not ok 4\n"}

for $x (@x) {
	unlink("$tmp/$x");
}
rmdir($tmp);

