use Pod::Perl5::Grammar;

module Pod::Perl5:ver<0.05>
{
  our sub parse_file (Str:D $filepath)
  {
    my $match = Pod::Perl5::Grammar.parsefile($filepath);

    unless ($match)
    {
      die "Error parsing pod";
    }
    return $match;
  }

  our sub parse_string (Str:D $pod)
  {
    my $match = Pod::Perl5::Grammar.parse($pod);

    unless ($match)
    {
      die "Error parsing pod";
    }
    return $match;
  }
}

