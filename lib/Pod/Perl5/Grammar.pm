grammar Pod::Perl5::Grammar
{
  token TOP
  {
    ^ [ <pod_section> | <?!before <pod_section> > .]* $
  }

  token pod_section
  {
    # start with a command block
    [
      <head1>|<head2>|<head3>|<head4>|<pod>|<encoding>|<for>|<over_back>|<begin_end>
    ]

    # any number of pod sections thereafter
    [
      <paragraph>|<verbatim_paragraph>|<over_back>|<for>|<begin_end>|
      <head1>|<head2>|<head3>|<head4>|<pod>|<encoding>|<cut>|<blank_line>
    ]*

    # must end on =cut or the end of the string
    [
      <cut>|$
    ]
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

  token blank_line
  {
    ^^ \h*? \n
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
    \V+
  }

  # can't include formatting code chars >, /, or |
  token singleline_format_text
  {
    <-[\v\>\/\|]>+
  }

  # multiline text can break over lines, but not blank lines.
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
  token pod       { ^^\=pod \h* \n }
  token cut       { ^^\=cut \h* \n }
  token encoding  { ^^\=encoding \h+ <name> \h* \n }

  # list processing
  token over_back { <over>
                    [
                      <_item> | <paragraph> | <verbatim_paragraph> | <blank_line> |
                      <for> | <begin_end> | <pod> | <encoding> | <over_back>
                    ]*
                    <back>
                  }

  token over      { ^^\=over [\h+ <[0..9]>+ ]? \n }
  token _item     { ^^\=item \h+ <name>
                    [
                        [ \h+ <paragraph>  ]
                      | [ \h* \n <blank_line> <paragraph>? ]
                    ]
                  }
  token back      { ^^\=back \h* \n }

  # format processing
  # begin/end blocks cannot be nested
  # so we store the current begin block name
  # to use for matching the end block
  my $begin_end_name;

  token begin_end { <begin> <begin_end_content> <_end> }
  token begin     { ^^\=begin \h+ <name> \h* \n { $begin_end_name = $/<name>.Str } }
  # end() causes a namespace clash, changed to _end
  token _end       { ^^\=end \h+ $begin_end_name \h* \n }

  token begin_end_content
  {
  [ <?!before <_end>> . ]*
  }

  token for       { ^^\=for \h <name> \h+ <singleline_text> \n }

  # headers
  token head1     { ^^\=head1 \h+ <singleline_text> \n }
  token head2     { ^^\=head2 \h+ <singleline_text> \n }
  token head3     { ^^\=head3 \h+ <singleline_text> \n }
  token head4     { ^^\=head4 \h+ <singleline_text> \n }

  # basic formatting codes
  token format_codes  { [<italic>|<bold>|<code>|<link>|<escape>|<filename>|<singleline>|<index>|<zeroeffect>] }
  token italic        { I\< <multiline_text>  \>  }
  token bold          { B\< <multiline_text>  \>  }
  token code          { C\< <multiline_text>  \>  }
  token escape        { E\< <singleline_format_text> \>  }
  token filename      { F\< <singleline_format_text> \>  }
  token singleline    { S\< <singleline_format_text> \>  }
  token index         { X\< <singleline_format_text> \>  }
  token zeroeffect    { Z\< <singleline_format_text> \>  }

  # links are more complicated
  token link          { L\<
                         [
                            [ <url>  ]
                          | [ <singleline_format_text> \| <url> ]
                          | [ <name> \| <section> ]
                          | [ <name> [ \|? \/ <section> ]? ]
                          | [ \/ <section> ]
                          | [ <singleline_format_text> \| <name> \/ <section> ]
                         ]
                        \>
                      }
  token url           { [ https? | ftp ] '://' <-[\v\>\|]>+ }
}
