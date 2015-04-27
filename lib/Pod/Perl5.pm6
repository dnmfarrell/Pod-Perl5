use Pod::Perl5::Grammar;

module Pod::Perl5:ver<0.02>
{
  our sub parse_file (Str:D $filepath)
  {
    my $pod = $filepath.IO.slurp;
    return parse_string($pod);
  }

  our sub parse_string (Str:D $pod, $action?)
  {
    my $match = Pod::Perl5::Grammar.parse($pod);

    unless ($match)
    {
      die "Error parsing pod";
    }
    return $match;
  }
}

