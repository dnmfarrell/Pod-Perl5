use Test;
use lib 'lib';

plan 2;

use Pod::Perl5; pass "Import Pod::Perl5";

ok Pod::Perl5::parse_string("=pod\n\nParagraph 1\n\n=cut\n"), 'parse string';

