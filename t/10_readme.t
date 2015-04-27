use Test;
use lib 'lib';

plan 9;

use Pod::Perl5; pass "Import Pod::Perl5";

ok my $match = Pod::Perl5::parse_file('test-corpus/readme_example.pod'),
  'parse readme example';

# basic counts
is $match<pod_section>[0]<head1>.elems,     7, 'Parser extracted seven headings';
is $match<pod_section>[0]<paragraph>.elems, 6, 'Parser extracted six paragraphs';
is $match<pod_section>[0]<verbatim_paragraph>.elems, 4, 'Parser extracted four verbatim paragraphs';

# value checks
is $match<pod_section>[0]<head1>[3]<singleline_text>.Str, "SYNOPSIS", 'Parser extracted value from paragraph';
is $match<pod_section>[0]<paragraph>[1]<text>.Str, "0.01\n", 'Parser extracted value from paragraph';
is $match<pod_section>[0]<paragraph>[2]<text><format_codes>[0]<code><multiline_text>.Str, "Pod::Perl5::Grammar",
  'Parser extracted value from paragraph';
is $match<pod_section>[0]<verbatim_paragraph>[0]<verbatim_text>.Str, "  use Pod::Perl5;\n",
  'Parser extracted text from verbatim paragraph';
