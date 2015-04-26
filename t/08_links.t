use Test;
use lib 'lib';

plan 14;

use Pod::Perl5; pass "Import Pod::Perl5";

ok my $match = Pod::Perl5::parse_file('test-corpus/links.pod'), 'parse links';

is $match<paragraph>.elems, 11, 'Parser extracted ten paragraphs';

is $match<paragraph>[0]<text><format_codes>[0]<link><name>.Str,
'Some::Name', 'Parser extract the correct name';

is $match<paragraph>[1]<text><format_codes>[0]<link><section>.Str,
'section', 'Parser extracted the correct section';

is $match<paragraph>[2]<text><format_codes>[0]<link><section>.Str,
'section', 'Parser extracted the correct section';

is $match<paragraph>[3]<text><format_codes>[0]<link><name>.Str,
'Some::Name', 'Parser extracted the correct name';

is $match<paragraph>[4]<text><format_codes>[0]<link><name>.Str,
'Some::Name', 'Parser extracted the correct name';

is $match<paragraph>[5]<text><format_codes>[0]<link><link_text>.Str,
'Some text', 'Parser extracted the correct text';

is $match<paragraph>[6]<text><format_codes>[0]<link><url>.Str,
'http://example.com', 'Parser extracted the url';
#
is $match<paragraph>[7]<text><format_codes>[0]<link><url>.Str,
'http://example.com', 'Parser extracted the url';

is $match<paragraph>[8]<text><format_codes>[0]<link><url>.Str,
'https://example.com', 'Parser extracted the url';

is $match<paragraph>[9]<text><format_codes>[0]<link><url>.Str,
'ftp://example.com', 'Parser extracted the url';

is $match<paragraph>[10]<text><format_codes>[0]<link><name>.Str,
'Some::Module', 'Parser extract the correct name';

