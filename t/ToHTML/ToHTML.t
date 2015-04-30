use Test;
use lib 'lib';
use Pod::Perl5;

plan 2;

use Pod::Perl5::ToHTML; pass 'Import ToHTML';

ok my $actions = Pod::Perl5::ToHTML.new, 'constructor';

my $pod = 'test-corpus/readme_example.pod'.IO.slurp;
ok Pod::Perl5::parse-string($pod, :$actions), 'convert string to html';
okPod::Perl5::parse-file('test-corpus/readme_example.pod', :actions(Pod::Perl5::ToHTML.new)), 'convert file to html';

