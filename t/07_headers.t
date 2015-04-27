use Test;
use lib 'lib';

plan 10;

use Pod::Perl5; pass "Import Pod::Perl5";

ok my $match = Pod::Perl5::parse_file('test-corpus/headers.pod'), 'parse headers';

is $match<pod_section>[0]<head1>.elems, 1, 'Parser extracted one head1';
is $match<pod_section>[0]<head1>[0]<singleline_text>.Str, "heading 1", 'Parser extracted header 1';

is $match<pod_section>[0]<head2>.elems, 1, 'Parser extracted one head2';
is $match<pod_section>[0]<head2>[0]<singleline_text>.Str, "heading 2", 'Parser extracted header 2';

is $match<pod_section>[0]<head3>.elems, 1, 'Parser extracted one head3';
is $match<pod_section>[0]<head3>[0]<singleline_text>.Str, "heading 3", 'Parser extracted header 3';

is $match<pod_section>[0]<head4>.elems, 1, 'Parser extracted one head4';
is $match<pod_section>[0]<head4>[0]<singleline_text>.Str, "heading 4", 'Parser extracted header 4';

