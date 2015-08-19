use Test;
use lib 'lib';
use Pod::Perl5::PerlTricks::Grammar;

plan 1;

ok my $match
  = Pod::Perl5::PerlTricks::Grammar.parsefile('test-corpus/PerlTricks/SampleArticle.pod'),
  'parse sample article';

say $match<pod-section>[0]<command-block>[4];
