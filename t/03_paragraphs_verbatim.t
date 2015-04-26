use Test;
use lib 'lib';

plan 4;

use Pod::Perl5; pass "Import Pod::Perl5";

ok my $match = Pod::Perl5::parse_file('test-corpus/paragraphs_advanced.pod'), 'parse paragraphs with verbatim example';
is $match<paragraph>.elems, 2, 'Parser extracted two paragraphs';
is $match<verbatim_paragraph>.elems, 1, 'Parser extracted one verbatim paragraph';
