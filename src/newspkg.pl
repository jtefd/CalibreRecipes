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
	'out=s'
);

$RECIPE_DIR = $opts{'recipes'} || '/usr/local/share/calibre/recipes';
$OUT_DIR = $opts{'out'} || '/var/www/newspkg';
$HEADER = 'Tefd.co.uk NewsPkg';
$INDEX_FILE_NAME = 'TefdNewsPkg.txt';
$BASE_URL = 'http://tefd.co.uk/news';

if (!-d $OUT_DIR) {
	mkdir $OUT_DIR or die "Failed creating output directory \"$OUT_DIR\" ($!)";
}


opendir(my $recipe_dir_h, $RECIPE_DIR) or die "Failed reading from source directory \"$RECIPE_DIR\" ($!)";

foreach my $recipe (grep {/\.recipe$/} readdir $recipe_dir_h) {
	my $recipe_path = catfile(rel2abs($RECIPE_DIR), $recipe);

	my $ebook_path = catfile(rel2abs($OUT_DIR), $recipe);
	$ebook_path =~ s/recipe$/mobi/;

	system("ebook-convert \"$recipe_path\" \"$ebook_path\"");
}

closedir $recipe_dir_h;

open(my $index_file_h, '>', catfile($OUT_DIR, 'index.html'));

print $index_file_h <<END;
<html>
	<head>
		<title>$HEADER</title>
	</head>
	<body>
		<h1>$HEADER</h1>

		<hr />
		
		<table>	
END

opendir(my $out_dir_h, $OUT_DIR);

foreach my $newsfile (grep {/\.mobi$/} readdir $out_dir_h) {
	my ($shortname) = ($newsfile =~ /(.*)\.mobi$/);

	$shortname = ucfirst $shortname;

	if (lc "$shortname.txt" eq lc $INDEX_FILE_NAME) {
		next;
	}

	print $index_file_h <<END;
		<tr>
			<td>
				<a href=$BASE_URL/$newsfile>
					$shortname
				</a>
			</td>
		</tr>
END
}

print $index_file_h <<END;
		<tr>
			<td>
				<a href=$BASE_URL/$INDEX_FILE_NAME>
					Index File
				</a>
			</td>
		</tr>
END

closedir $out_dir_h;

print $index_file_h <<END;
		</table>
	</body>
</html>
END

close $index_file_h;

copy catfile($OUT_DIR, 'index.html'), catfile($OUT_DIR, $INDEX_FILE_NAME);
