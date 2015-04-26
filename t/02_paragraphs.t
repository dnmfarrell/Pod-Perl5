use Test;
use lib 'lib';

plan 6;

use Pod::Perl5; pass "Import Pod::Perl5";

ok my $match = Pod::Perl5::parse_file('test-corpus/paragraphs_simple.pod'), 'parse paragraphs';

is $match<paragraph>.elems, 3, 'Parser extracted three paragraphs';

is $match<paragraph>[0]<text>.Str,
  'paragraph one', 'Paragraph text extracted successfully';

is $match<paragraph>[1]<text>.Str,
  "paragraph two\nparagraph two", 'Paragraph text extracted successfully';

is $match<paragraph>[2]<text>.Str,
  "paragraph three\nparagraph three\nparagraph three", 'Paragraph text extracted successfully';
