use Test;
use lib 'lib';
use Pod::Perl5;

plan 4;

use Pod::Perl5::ToHTML; pass 'Import ToHTML';

ok my $actions = Pod::Perl5::ToHTML.new, 'constructor';

my $pod = 'test-corpus/readme_example.pod'.IO.slurp;
ok Pod::Perl5::string-to-html($pod), 'convert string to html';
ok Pod::Perl5::file-to-html('test-corpus/readme_example.pod'), 'convert file to html';

