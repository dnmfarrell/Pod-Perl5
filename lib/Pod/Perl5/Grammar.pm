use Grammar::Tracer;

grammar Pod::Perl5::Grammar
{
  token TOP
  {
    ^ [<paragraph>|<verbatim_paragraph>|<over_back>]* $
  }

  # verbatim paragraph is a paragraph that begins with horizontal whitespace
  token verbatim_paragraph
  {
    ^^\h+? \S.+? <blank_line>
  }

  # paragraph is a stream beginning with a non-whitespace char (and not =)
  token paragraph
  {
    <?!before \=> \S .+? <blank_line>
  }

  # blank line is a stream of whitespace surrounded by newlines
  token blank_line
  {
    \n\h*?\n
  }

  # name is a continuous stream of text without whitespace
  token name
  {
    \S+
  }

  # command paragraphs
  token pod       { ^^\=pod <blank_line> }
  token cut       { ^^\=cut <blank_line> }
  token encoding  { ^^\=encoding \h <name> \h* <blank_line> }

  # list processing
  token over_back { <over>
                    [
                      <item> | <paragraph> | <verbatim_paragraph> | <for> |
                      <begin_end> | <pod> | <encoding>
                    ]*
                    <back>
                  }

  token over      { ^^\=over [\h<[0..9]>]? <blank_line> }
  token item      { ^^\=item \h+ [\*|<[0..9]>+] [\h*<paragraph>]|[\h*<blank_line><paragraph>] }
  token back      { ^^\=back <blank_line> }

  # format processing
  token begin_end { <begin> .* <end> }
  token begin     { ^^\=begin \h <name> <blank_line>}
  token end       { ^^\=end \h <name> <blank_line>  }
  token for       { ^^\=for \h <name> \h+ <paragraph> }

  # headers
  token head1     { ^^\=head1 \h <paragraph> }
  token head2     { ^^\=head2 \h <paragraph> }
  token head3     { ^^\=head3 \h <paragraph> }
  token head4     { ^^\=head4 \h <paragraph> }

  # TODO formatting codes
}
