use Test;
use lib 'lib';

plan 17;

use Pod::Perl5::PerlTricks::Grammar; pass 'import module';

ok my $match
  = Pod::Perl5::PerlTricks::Grammar.parsefile('test-corpus/PerlTricks/SampleArticle.pod'),
  'parse sample article';

is $match<pod-section>[0]<command-block>[1]<singleline-text>.Str,
  'Separate data and behavior with table-driven testing',
  'title';

is $match<pod-section>[0]<command-block>[2]<singleline-text>.Str,
  'Applying DRY to unit testing',
  'subtitle';

is $match<pod-section>[0]<command-block>[3]<datetime>.Str,
  '2000-12-31T00:00:00',
  'publish-date';

ok my $include = $match<pod-section>[0]<command-block>[4]<file>.made, 'Extract the =include pod';
is $include<pod-section>[0]<command-block>[0]<singleline-text>, 'brian d foy', 'author-name matches expected';

is $match<pod-section>[0]<command-block>[5]<name>.elems, 6, '6 tags found';
is $match<pod-section>[0]<command-block>[5]<name>[3], 'table', 'matched table tag';

is $match<pod-section>[0]<command-block>[6]<format-code><url>, 'file://onion_charcoal.png', 'cover-image url';

is $match<pod-section>[0]<paragraph>[1]<multiline-text><format-code>[1]<name>, 'String::Sprintf', 'M<> format code';

is $match<pod-section>[0]<paragraph>.elems, 16, 'matched all paragraphs';
is $match<pod-section>[0]<verbatim-paragraph>.elems, 9, 'matched all verbatim paragraphs';

ok my $table = $match<pod-section>[0]<command-block>[7], 'table';
is $table<header-row><header-cell>.elems, 3, 'match 3 headings';
is $table<header-row><header-cell>[2].Str, 'ColC', 'match third heading';
is $table<row>[1]<cell>[1].Str, '1234', 'match middle cell';



