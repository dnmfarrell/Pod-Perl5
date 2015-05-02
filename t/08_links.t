use Test;
use lib 'lib';

plan 14;

use Pod::Perl5; pass "Import Pod::Perl5";

ok my $match = Pod::Perl5::parse-file('test-corpus/links.pod'), 'parse links';

is $match<pod_section>[0]<paragraph>.elems, 11, 'Parser extracted ten paragraphs';

is $match<pod_section>[0]<paragraph>[0]<paragraph_node>[0]<format_codes><name>.Str,
'Some::Name', 'Parser extract the correct name';

is $match<pod_section>[0]<paragraph>[1]<paragraph_node>[0]<format_codes><section>.Str,
'section', 'Parser extracted the correct section';

is $match<pod_section>[0]<paragraph>[2]<paragraph_node>[0]<format_codes><section>.Str,
'section', 'Parser extracted the correct section';

is $match<pod_section>[0]<paragraph>[3]<paragraph_node>[0]<format_codes><name>.Str,
'Some::Name', 'Parser extracted the correct name';

is $match<pod_section>[0]<paragraph>[4]<paragraph_node>[0]<format_codes><name>.Str,
'Some::Name', 'Parser extracted the correct name';

is $match<pod_section>[0]<paragraph>[5]<paragraph_node>[0]<format_codes><singleline_format_text>.Str,
'Some text', 'Parser extracted the correct text';

is $match<pod_section>[0]<paragraph>[6]<paragraph_node>[0]<format_codes><url>.Str,
'http://example.com', 'Parser extracted the url';
#
is $match<pod_section>[0]<paragraph>[7]<paragraph_node>[0]<format_codes><url>.Str,
'http://example.com', 'Parser extracted the url';

is $match<pod_section>[0]<paragraph>[8]<paragraph_node>[0]<format_codes><url>.Str,
'https://example.com', 'Parser extracted the url';

is $match<pod_section>[0]<paragraph>[9]<paragraph_node>[0]<format_codes><url>.Str,
'ftp://example.com', 'Parser extracted the url';

is $match<pod_section>[0]<paragraph>[10]<paragraph_node>[1]<format_codes><name>.Str,
'Some::Module', 'Parser extract the correct name';

