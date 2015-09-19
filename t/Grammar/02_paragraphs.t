use Test;
use lib 'lib';

plan 6;

use Pod::Perl5::Grammar; pass "Import Pod::Perl5::Grammar";

ok my $match = Pod::Perl5::Grammar.parsefile('test-corpus/paragraphs_simple.pod'), 'parse paragraphs';

is $match<pod-section>[0]<paragraph>.elems, 3, 'Parser extracted three paragraphs';

is $match<pod-section>[0]<paragraph>[0].Str,
  "paragraph one\n", 'Paragraph text extracted successfully';

is $match<pod-section>[0]<paragraph>[1].Str,
  "paragraph two\nparagraph two\n", 'Paragraph text extracted successfully';

is $match<pod-section>[0]<paragraph>[2].Str,
  "paragraph three\nparagraph three\nparagraph three\n", 'Paragraph text extracted successfully';

