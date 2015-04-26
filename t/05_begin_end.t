use Test;
use lib 'lib';

plan 7;

use Pod::Perl5; pass "Import Pod::Perl5";

ok my $match = Pod::Perl5::parse_file('test-corpus/begin_end.pod'), 'parse begin/end command';
is $match<begin_end>.elems, 2, 'Parser extracted two begin/end pairs';

# block 1
is $match<begin_end>[0]<begin><name>.Str, 'HTML', 'The name from first begin pair is HTML';
is $match<begin_end>[0]<end><name>.Str, 'HTML', 'The name from first end pair is HTML';

# block 2
is $match<begin_end>[1]<begin><name>.Str, 'some_text', 'The name from first begin pair is some_text';
is $match<begin_end>[1]<end><name>.Str, 'some_text', 'The name from first end pair is some_text';
