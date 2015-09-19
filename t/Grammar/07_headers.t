use Test;
use lib 'lib';

plan 7;

use Pod::Perl5::Grammar; pass "Import Pod::Perl5::Grammar";

ok my $match = Pod::Perl5::Grammar.parsefile('test-corpus/headers.pod'), 'parse headers';

is $match<pod-section>[0]<command-block>.elems, 4, 'Parser extracted four comamnd blocks';
is $match<pod-section>[0]<command-block>[0]<singleline-text>.Str, "heading 1", 'Parser extracted header 1';

is $match<pod-section>[0]<command-block>[1]<singleline-text>.Str, "heading 2", 'Parser extracted header 2';

is $match<pod-section>[0]<command-block>[2]<singleline-text>.Str, "heading 3", 'Parser extracted header 3';

is $match<pod-section>[0]<command-block>[3]<singleline-text>.Str, "heading 4", 'Parser extracted header 4';

