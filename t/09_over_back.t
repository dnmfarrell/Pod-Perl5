use Test;
use lib 'lib';

plan 20;

use Pod::Perl5; pass "Import Pod::Perl5";

ok my $match = Pod::Perl5::parse_file('test-corpus/over_back.pod'), 'parse over_back';
is $match<over_back>.elems, 3, 'Parser extracted two over/back pair';

# tests for list 1
is $match<over_back>[0]<_item>[0]<name>.Str, '1', 'Parser extracted name from bullet point one';
is $match<over_back>[0]<_item>[0]<paragraph>.Str, "bullet point one\n\n",
  'Parser extracted paragraph from bullet point one';

is $match<over_back>[0]<_item>[1]<name>.Str, '*', 'Parser extracted name from bullet point two';
is $match<over_back>[0]<_item>[1]<paragraph>.Str, "bullet point two\n\n",
  'Parser extracted paragraph from bullet point two';

is $match<over_back>[0]<_item>[2]<name>.Str,
  'some_code()',
  'Parser extracted name from bullet point three';

is $match<over_back>[0]<_item>[2]<paragraph>.Str,
  "bullet point three\n\n",
  'Parser extracted paragraph from bullet point three';

is $match<over_back>[0]<_item>[3]<name>.Str, 'NoPara',
  'Parser extracted name from bullet point four';

is $match<over_back>[0]<_item>[4]<name>.Str,
  'NoParaTrailingWhitespace',
  'Parser extracted name from bullet point five';

is $match<over_back>[0]<_item>[5]<name>,
  'ParaNextLine',
  'Parser extracted name from bullet point six';

is $match<over_back>[0]<_item>[5]<paragraph>.Str,
  "This is the para for the bullet point\n\n",
  'Parser extracted paragraph from bullet point seven';

is $match<over_back>[0]<_item>[6]<name>,
  'ParaNextLineTrailWhitespace',
  'Parser extracted name from bullet point seven';

is $match<over_back>[0]<_item>[6]<paragraph>.Str,
  "This is the para for the bullet point after trailing whitespace\n\n",
  'Parser extracted paragraph from bullet point seven';

is $match<over_back>[0]<pod>.Str,
  "=pod\n\n",
  'Pod was extracted from within the list';

# tests for list 2
is $match<over_back>[1]<over>.Str,
  "=over 4\n\n",
  'Extracted the over and the number';

is $match<over_back>[1]<_item>.elems,
  3, 'Extracted three items from the second list';

# tests for list 3
is $match<over_back>[2]<over_back>[0]<_item>.elems,
  2, 'The inner list has two items';

is $match<over_back>[2]<_item>.elems,
  3, 'The outer list has three items';

