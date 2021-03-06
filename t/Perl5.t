#!/usr/bin/env perl6
use Test;
use lib 'lib';

plan 5;

use Pod::Perl5; pass "Import Pod::Perl5";
ok Pod::Perl5::parse-string("=pod\n\nParagraph 1\n\n=cut\n"), 'parse string';
ok Pod::Perl5::parse-file('t/test-corpus/readme_example.pod'), 'parse document';
ok Pod::Perl5::file-to-html('t/test-corpus/readme_example.pod'), 'parse document';
ok Pod::Perl5::file-to-markdown('t/test-corpus/readme_example.pod'), 'parse document';
