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
  token multiline_text
  {
    [ <format_codes> | <?!before [ <blank_line> | \> ]> . ]+
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
  # begin/end blocks cannot be nested
  # so we store the current begin block name
  # to use for matching the end block
  my $begin_end_name;

  token begin_end { <begin> <begin_end_content> <end> }
  token begin     { ^^\=begin \h+ <name> <blank_line> { $begin_end_name = $/<name>.Str } }
  token end       { ^^\=end \h+ $begin_end_name <blank_line> }

  token begin_end_content
  {
    [<?!before <end>>. ]*
  }

  token for       { ^^\=for \h <name> \h+ <paragraph> }

  # headers
  token head1     { ^^\=head1 \h+ <singleline_text> <blank_line> }
  token head2     { ^^\=head2 \h+ <singleline_text> <blank_line> }
  token head3     { ^^\=head3 \h+ <singleline_text> <blank_line> }
  token head4     { ^^\=head4 \h+ <singleline_text> <blank_line> }

  # basic formatting codes
  # TODO enable formatting within formatting
  token format_codes  { [<italic>|<bold>|<code>|<link>|<escape>|<filename>|<singleline>|<index>|<zeroeffect>] }
  token italic        { I\< <multiline_text>  \>  }
  token bold          { B\< <multiline_text>  \>  }
  token code          { C\< <multiline_text>  \>  }
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
