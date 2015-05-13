use Pod::Perl5::Grammar;
use Pod::Perl5::ToHTML;

module Pod::Perl5:ver<0.07>
{
  our sub parse-file (Str:D $filepath, $actions?)
  {
    my $match;

    if $actions
    {
      $match = Pod::Perl5::Grammar.parsefile($filepath, :$actions);
    }
    else
    {
      $match = Pod::Perl5::Grammar.parsefile($filepath);
    }

    unless ($match)
    {
      die "Error parsing pod";
    }
    return $match;
  }

  our sub parse-string (Str:D $pod, $actions?)
  {
    my $match;

    if $actions
    {
      $match = Pod::Perl5::Grammar.parse($pod, :$actions);
    }
    else
    {
      $match = Pod::Perl5::Grammar.parse($pod);
    }

    unless ($match)
    {
      die "Error parsing pod";
    }
    return $match;
  }

  our sub string-to-html (Str:D $pod)
  {
    parse-string($pod, Pod::Perl5::ToHTML.new);
  }

  our sub file-to-html (Str:D $filepath)
  {
    parse-file($filepath, Pod::Perl5::ToHTML.new);
  }
}

