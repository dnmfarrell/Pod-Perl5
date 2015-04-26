use Test;
use lib 'lib';

plan 3;

use Pod::Perl5; pass "Import Pod::Perl5";

ok my $match = Pod::Perl5::parse_file('test-corpus/paragraphs_simple.pod'), 'parse paragraphs';
is $match<paragraph>.elems, 3, 'Parser extracted three paragraphs';
