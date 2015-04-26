#use Grammar::Tracer;

grammar Pod::Perl5::Grammar
{
  token TOP
  {
    ^ [
        <paragraph>|<verbatim_paragraph>|<over_back>|<for>|<begin_end>|
        <head1>|<head2>|<head3>|<head4>|<pod>|<encoding>|<cut>
      ]*
    $
  }

  token verbatim_paragraph
  {
    <verbatim_text> <blank_line>
  }

  token paragraph
  {
    <text> <blank_line>
  }

  # paragraph text is a stream of text and/or format codes
  # beginning with a non-whitespace char (not =) or a format code
  # and not containing a blank line
  token text
  {
    <?!before \=>
    [<format_codes>|<?!before <format_codes>> \S]
    [<format_codes>|<?!before [<format_codes>|<blank_line>]> . ]*
  }

  # verbatim text is text that begins on a newline with horizontal whitespace
  token verbatim_text
  {
    ^^\h+? \S [ <?!before <blank_line>> . ]*
  }

  # blank line is a stream of whitespace surrounded by newlines
  token blank_line
  {
    \n\h*?[\n|$]
  }

  # tokens for matching streams of text in formatting codes
  # none of them can contain ">" as it's the closing char of 
  # a formatting sequence
  token name
  {
    <-[\s\>\/\|]>+
  }

  token singleline_text
  {
    <-[\v\>\/\|]>+
  }

  # multinline text can break over lines, but not blank lines.
  # Should add that restriction here
  token multiline_text
  {
    <-[ \> ]>+
  }

  # section has the same definition as singleline text, but we have a different token
  # in order to be able to distinguish between text and section when they're
  # both present in a link tag eg. "L<This is text|Module::Name/ThisIsTheSection>"
  token section
  {
    <-[\v\>\/\|]>+
  }

  # command paragraphs
  token pod       { ^^\=pod <blank_line> }
  token cut       { ^^\=cut <blank_line> }
  token encoding  { ^^\=encoding \h <name> \h* <blank_line> }

  # list processing
  token over_back { <over>
                    [
                      <_item> | <paragraph> | <verbatim_paragraph> | <for> |
                      <begin_end> | <pod> | <encoding> | <over_back>
                    ]*
                    <back>
                  }

  token over      { ^^\=over [\h<[0..9]>]? <blank_line> }
  token _item     { ^^\=item \h+ <name>
                    [
                        [ \h+ <paragraph>  ]
                      | [ \h* <blank_line> <paragraph>? ]
                    ]
                  }
  token back      { ^^\=back <blank_line> }

  # format processing
  # TODO check the name matches for the begin/end pair
  token begin_end { <begin> .*? <end> }
  token begin     { ^^\=begin \h+ <name> <blank_line>}
  token end       { ^^\=end \h+ <name>  <blank_line>  }
  token for       { ^^\=for \h <name> \h+ <paragraph> }

  # headers
  token head1     { ^^\=head1 \h+ <paragraph> }
  token head2     { ^^\=head2 \h+ <paragraph> }
  token head3     { ^^\=head3 \h+ <paragraph> }
  token head4     { ^^\=head4 \h+ <paragraph> }

  # basic formatting codes
  # TODO enable formatting within formatting
  token format_codes  { [<italic>|<bold>|<code>|<link>] }
  token italic        { I\< <multiline_text> \>  }
  token bold          { B\< <multiline_text> \>  }
  token code          { C\< <multiline_text> \>  }
  token escape        { E\< <singleline_text> \>  }
  token filename      { F\< <singleline_text> \>  }
  token singleline    { S\< <singleline_text> \>  }
  token index         { X\< <singleline_text> \>  }
  token zeroeffect    { Z\< <singleline_text> \>  }

  # links are more complicated
  token link          { L\<
                         [
                            [ <url>  ]
                          | [ <singleline_text> \| <url> ]
                          | [ <name> \| <section> ]
                          | [ <name> [ \|? \/ <section> ]? ]
                          | [ \/ <section> ]
                          | [ <singleline_text> \| <name> \/ <section> ]
                         ]
                        \>
                      }
  token url           { [ https? | ftp ] '://' <-[\v\>\|]>+ }
}
