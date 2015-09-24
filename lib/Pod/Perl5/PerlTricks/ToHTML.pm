class Pod::Perl5::PerlTricks::ToHTML
{
  # table handling
  method command-block:table ($match)
  {
    my @table_tags = '<table>', $match<header-row>.made;

    for $match<row>.values -> $row
    {
      @table_tags.push("<tr>{$row.made}</tr>");
    }
    @table_tags.push("</table>");
    $match.make(join("\n", @table_tags));
  }
  method header-row ($match)
  {
    my $cells;

    for $match<header-cell>.values -> $cell
    {
      $cells ~= $cell.made;
    }
    $match.make($cells);
  }
  method row ($match)
  {
    my $cells;

    for $match<cell>.values -> $cell
    {
      $cells ~= $cell.made;
    }
    $match.make($cells);
  }
  method header-cell ($match)
  {
    $match.make("<th>{$match}</th>");
  }
  method cell ($match)
  {
    $match.make("<td>{$match}</td>");
  }
}
