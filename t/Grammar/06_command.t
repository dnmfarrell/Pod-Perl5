use Test;
use lib 'lib';

plan 4;

use Pod::Perl5::Grammar; pass "Import Pod::Perl5::Grammar";

ok my $match = Pod::Perl5::Grammar.parsefile('test-corpus/command.pod'), 'parse command';

is $match<pod-section>[0]<command-block>.elems, 2, 'Parser extracted three command paragraphs';

is $match<pod-section>[0]<command-block>[1]<name>.Str, 'utf8', 'Parser extracted encoding name is utf8';

