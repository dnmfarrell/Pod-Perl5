use Test;
use lib 'lib';

plan 5;

use Pod::Perl5; pass "Import Pod::Perl5";

ok my $match = Pod::Perl5::parse_file('test-corpus/paragraphs_advanced.pod'),
  'parse paragraphs with verbatim example';

is $match<paragraph>.elems, 2,
  'Parser extracted two paragraphs';

is $match<verbatim_paragraph>.elems, 1,
  'Parser extracted one verbatim paragraph';

is $match<verbatim_paragraph>[0]<verbatim_text>.Str,
  qq/  use strict;\n  print "Hello, World!\\n";/, # escape the literal newline
  'Parser extracted the verbatim text';
