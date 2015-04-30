use Test;
use lib 'lib';

plan 6;

use Pod::Perl5; pass "Import Pod::Perl5";

ok my $match = Pod::Perl5::parse-file('test-corpus/paragraphs_simple.pod'), 'parse paragraphs';

is $match<pod_section>[0]<paragraph>.elems, 3, 'Parser extracted three paragraphs';

is $match<pod_section>[0]<paragraph>[0]<text>.Str,
  "paragraph one\n", 'Paragraph text extracted successfully';

is $match<pod_section>[0]<paragraph>[1]<text>.Str,
  "paragraph two\nparagraph two\n", 'Paragraph text extracted successfully';

is $match<pod_section>[0]<paragraph>[2]<text>.Str,
  "paragraph three\nparagraph three\nparagraph three\n", 'Paragraph text extracted successfully';

