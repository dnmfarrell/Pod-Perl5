use Test;
use lib 'lib';

plan 6;

use Pod::Perl5; pass "Import Pod::Perl5";

ok my $match = Pod::Perl5::parse_file('test-corpus/command.pod'), 'parse command';

# pod, cut
is $match<pod>.elems, 1, 'Parser extracted one pod';
is $match<cut>.elems, 1, 'Parser extracted one cut';

# encoding
is $match<encoding>.elems, 1, 'Parser extracted one encoding';
is $match<encoding>[0]<name>.Str, 'utf8', 'Parser extracted encoding name is utf8';
  'Parser extracted the paragraph';
