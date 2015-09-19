use Test;
use lib 'lib';
use Pod::Perl5::Grammar;
use Pod::Perl5::ToHTML;

plan 3;

my $target_html = 'test-corpus/readme_example.html'.IO.slurp;

ok my $actions = Pod::Perl5::ToHTML.new, 'constructor';
ok my $match   = Pod::Perl5::Grammar.parsefile('test-corpus/readme_example.pod', :$actions),
  'convert string to html';
is $match.made, $target_html, 'Generated html matches expected';
#say $match.made;
