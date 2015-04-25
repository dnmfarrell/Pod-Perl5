use Test;
use lib 'lib';

plan 3;

use Pod::Perl5; pass "Import Pod::Perl5";

ok Pod::Perl5::parse_file('test-corpus/paragraphs_simple.pod'), 'parse paragraphs';
ok Pod::Perl5::parse_file('test-corpus/paragraphs_advanced.pod'), 'parse paragraphs advanced';
ok Pod::Perl5::parse_file('test-corpus/over_back.pod'), 'parse a list';

