#!/usr/bin/env perl

use strict;
use warnings;

use File::Spec::Functions qw/catfile rel2abs/;

use vars qw/$RECIPE_DIR $OUT_DIR/;

$RECIPE_DIR = '/usr/local/share/calibre/recipes';
$OUT_DIR = '/var/www/newspkg';

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
