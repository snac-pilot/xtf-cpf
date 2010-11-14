#!/bin/env perl
## Brian Tingle; SNAC Project; BSD License Copyright 2010 UC Regents
##
## script to call from XTF that looks for exact matches of the 
## name in dbpedia

use FindBin qw($Bin); 
# persondata-uniq is a list of all the dbpedia persondata URLs
# curl http://downloads.dbpedia.org/3.5.1/en/persondata_en.nt.bz2 | \
#   bzcat | awk '{ print $1 }' | uniq > persondata-uniq
# should parse this into a DB_File ?

my $data = "$Bin/persondata-uniq";
open (DATAFILE, $data);

my $string_in = $ARGV[0];
# Input is one argument; like "Oppenheimer, J. Robert, 1904-1967."
# ( actually OPPENHEIMER, J. ROBERT, 1904-1967.;)

# TODO add proper URL encoding for names outside english latin

# regex / cleanup
$string_in =~ s,(\d)-(\d),$1$2,;   # remove minus signs between digits
$string_in =~ s,\d{4},,g;          # remove four digits in a row
$string_in =~ s/^\s+|\s+$//g ;     # remove both leading and trailing whitespace
$string_in =~ s,\.+$,,;            # remove trailing .

# convert to direct order
my $direct_order =  join(" ", reverse(split(/,/ , $string_in ) ) );

$direct_order =~ s/^\s+|\s+$//g ;     # remove both leading and trailing whitespace
$direct_order =~ s,\s,_,g;            # change spaces to underscore
$direct_order =~ s,(\-|\(|\)),\\$1,g; # regex escape

# scan the data file; looking for matches
while (defined ($line = <DATAFILE>)) {
  if ($line =~ m,^<http://dbpedia.org/resource/$direct_order>$,i){
    $line =~ s,^<|>$,,g;
    chomp($line);
    print $line;
  }
}
