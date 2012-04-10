#!/usr/bin/env perl

use strict;
use warnings;

use Getopt::Long;
use File::Copy;
use File::Spec::Functions qw/catfile rel2abs/;
use Pod::Usage;

use vars qw/$BASE_URL $RECIPE_DIR $OUT_DIR $HEADER $INDEX_FILE_NAME/;

my %opts;

GetOptions(
	\%opts,
	'recipes=s',
	'out=s',
	'header=s',
	'baseurl=s',
	'indexfile=s',
	'gen-index'
);

$RECIPE_DIR = $opts{'recipes'};
$OUT_DIR = $opts{'out'};
$HEADER = $opts{'header'};
$INDEX_FILE_NAME = $opts{'indexfile'};
$BASE_URL = $opts{'baseurl'};

if (!-d $OUT_DIR) {
	mkdir $OUT_DIR or die "Failed creating output directory \"$OUT_DIR\" ($!)";
}

if (!defined($opts{'gen-index'})) {
	opendir(my $recipe_dir_h, $RECIPE_DIR) or die "Failed reading from source directory \"$RECIPE_DIR\" ($!)";

	foreach my $recipe (grep {/\.recipe$/} readdir $recipe_dir_h) {
		my $recipe_path = catfile(rel2abs($RECIPE_DIR), $recipe);

		my $ebook_path = catfile(rel2abs($OUT_DIR), $recipe);
		$ebook_path =~ s/recipe$/mobi/;

		system("ebook-convert \"$recipe_path\" \"$ebook_path\"");
	}

	closedir $recipe_dir_h;
}

open(my $index_file_h, '>', catfile($OUT_DIR, 'index.html'));

print $index_file_h <<END;
<html>
	<head>
		<title>$HEADER</title>
	</head>
	<body>
		<h1>$HEADER</h1>

		<hr />
		
		<ul>	
END

opendir(my $out_dir_h, $OUT_DIR);

foreach my $newsfile (grep {/\.mobi$/} readdir $out_dir_h) {
	my ($shortname) = ($newsfile =~ /(.*)\.mobi$/);

	if (lc "$shortname.txt" eq lc $INDEX_FILE_NAME) {
		next;
	}

	print $index_file_h <<END;
			<li>
				<a href=$BASE_URL/$newsfile>
					$shortname
				</a>
			</li>
END
}

print $index_file_h <<END;
		</ul>

		<hr />
	
		<ul>
			<li>
				<a href=$BASE_URL/$INDEX_FILE_NAME>
					Index File
				</a>
			</li>
END

closedir $out_dir_h;

print $index_file_h <<END;
		</ul>
	</body>
</html>
END

close $index_file_h;

copy catfile($OUT_DIR, 'index.html'), catfile($OUT_DIR, $INDEX_FILE_NAME);
