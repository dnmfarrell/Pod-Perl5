use Test;
use lib 'lib';

plan 3;

use Pod::Perl5; pass "Import Pod::Perl5";

ok my $string_match = Pod::Perl5::parse-string("=pod\n\nParagraph 1\n\n=cut\n"), 'parse string';
ok my $file_match   = Pod::Perl5::parse-file('test-corpus/readme_example.pod'), 'parse document';
