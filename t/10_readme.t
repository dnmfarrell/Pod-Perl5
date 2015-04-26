use Test;
use lib 'lib';

plan 9;

use Pod::Perl5; pass "Import Pod::Perl5";

ok my $match = Pod::Perl5::parse_file('test-corpus/readme_example.pod'),
  'parse readme example';

# basic counts
is $match<head1>.elems,     7, 'Parser extracted seven headings';
is $match<paragraph>.elems, 6, 'Parser extracted six paragraphs';
is $match<verbatim_paragraph>.elems, 4, 'Parser extracted four verbatim paragraphs';

# value checks
is $match<head1>[3]<paragraph>.Str, "SYNOPSIS\n\n", 'Parser extracted value from paragraph';
is $match<paragraph>[1].Str, "0.01\n\n", 'Parser extracted value from paragraph';
is $match<paragraph>[2]<format_codes>[0]<code><multiline_text>.Str, "Pod::Perl5::Grammar",
  'Parser extracted value from paragraph';
is $match<verbatim_paragraph>[0].Str, "  use Pod::Perl5;\n\n",
  'Parser extracted value from verbatim paragraph';
