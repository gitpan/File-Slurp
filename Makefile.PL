
use ExtUtils::MakeMaker;

WriteMakefile( 
	'VERSION_FROM' => 'lib/File/Slurp.pm',
	'NAME'	  => 'File::Slurp',
	'dist' => { COMPRESS=>"gzip", SUFFIX=>"gz" },
	($] >= 5.005 ?
	    ('ABSTRACT' => 'Read and write files with a single command',
	     'AUTHOR'	=> 'David Muir Sharnoff <muir@idiom.com>') : ()),
	);

