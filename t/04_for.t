use Test;
use lib 'lib';

plan 5;

use Pod::Perl5; pass "Import Pod::Perl5";

ok my $match = Pod::Perl5::parse_file('test-corpus/for.pod'), 'parse for command';

is $match<for>.elems, 1, 'Parser extracted one for';
is $match<for>[0]<name>.Str, 'HTML', 'Parser extracted name value is HTML';
is $match<for>[0]<paragraph><text>.Str, "<a href='#'>some inline hyperlink</a>", 
  'Parser extracted the paragraph';
