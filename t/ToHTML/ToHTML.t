use Test;
use lib 'lib';
use Pod::Perl5::Grammar;

plan 2;

use Pod::Perl5::ToHTML; pass 'Import ToHTML';

ok my $actions = Pod::Perl5::ToHTML.new, 'constructor';

my $pod = 'test-corpus/readme_example.pod'.IO.slurp;
say Pod::Perl5::Grammar.parse($pod, :$actions);

