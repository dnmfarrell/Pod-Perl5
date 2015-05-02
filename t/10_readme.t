use Test;
use lib 'lib';

plan 15;

use Pod::Perl5; pass "Import Pod::Perl5";

ok my $match = Pod::Perl5::parse-file('test-corpus/readme_example.pod'),
  'parse readme example';

# basic counts
is $match<pod_section>.elems,               1, 'Parser extracted one pod section';
is $match<pod_section>[0]<head1>.elems,     7, 'Parser extracted seven headings';
is $match<pod_section>[0]<paragraph>.elems, 6, 'Parser extracted six paragraphs';
is $match<pod_section>[0]<verbatim_paragraph>.elems, 4, 'Parser extracted four verbatim paragraphs';
is $match<pod_section>[0]<over_back>.elems, 1, 'Parser extracted one list';
is $match<pod_section>[0]<begin_end>.elems, 1, 'Parser extracted one begin/end block';
is $match<pod_section>[0]<_for>.elems,       1, 'Parser extracted one for block';
is $match<pod_section>[0]<pod>.elems,       1, 'Parser extracted one pod block';
is $match<pod_section>[0]<encoding>.elems,  1, 'Parser extracted one encoding block';

# value checks
is $match<pod_section>[0]<head1>[3]<singleline_text>.Str,
  "SYNOPSIS",
  'Parser extracted name from header';

is $match<pod_section>[0]<paragraph>[2]<paragraph_node>.Str,
  "0.01\n",
  'Parser extracted text from paragraph';

is $match<pod_section>[0]<paragraph>[3]<paragraph_node>[3]<format_codes><multiline_text>.Str,
  "Pod::Perl5::Grammar",
  'Parser extracted value from code formatting';

is $match<pod_section>[0]<verbatim_paragraph>[0]<verbatim_text>.Str,
  "  use Pod::Perl5;\n",
  'Parser extracted text from verbatim paragraph';

