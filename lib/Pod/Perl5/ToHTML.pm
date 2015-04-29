class Pod::Perl5::ToHTML
{

  # we default to stdout
  has $.output_filehandle = $*OUT;

  # this maps pod encoding values to their HTML equivalent
  # if no mapping is found, the pod encoding value will be
  # used
  has %.encoding_map = utf8 => 'UTF-8';

  # %html is where the converted markup is added
  has %!html = head => '', body => '';

  method add_to_html (Str:D $section_name, Str:D $string)
  {
    die "Section $section_name doesn't exist!" unless %!html{$section_name}:exists;
    %!html{$section_name} ~= $string;
  }

  # buffer is used as a temporary store when formatting needs to
  # be nested, e.g.: <p><i>some text</i></p>
  # the italicised text is stored in the paragraph buffer
  # and when the paragraph() executes, it replaces its
  # contents with the buffer
  has %!buffer = paragraph => (), _item => ();

  method get_buffer (Str:D $buffer_name) is rw
  {
    die ("buffer {$buffer_name} does not exist!") unless %!buffer{$buffer_name}:exists;
    return-rw %!buffer{$buffer_name}; # return-rw required, a naked "return" forces ro
  }

  method add_to_buffer (Str:D $buffer_name, Pair:D $pair)
  {
    my @buffer = self.get_buffer($buffer_name);
    @buffer.push: $pair;
  }

  method clear_buffer (Str:D $buffer_name)
  {
    self.get_buffer($buffer_name) = ()
  }

  # once parsing is complete, this method is executed
  # we format and print the $html
  method TOP ($/ is copy) # required as regex writes to $/, and $/ is read only by default
  {
    say $.output_filehandle, qq:to/END/;
      <html>
      { if my $head = %!html<head> { "<head>\n{$head}</head>\n" } }
      { if my $body = %!html<body>
        {
          # remove redundant pre tags
          "<body>\n{$body.subst(/\<\/pre\>\s*\<pre\>/, {''}, :g)}</body>\n"
        }
      }
      </html>
      END
  }

  method head1 ($/)
  {
    self.add_to_html('body', "<h1>{$/<singleline_text>.Str}</h1>\n");
  }

  method head2 ($/)
  {
    self.add_to_html('body', "<h2>{$/<singleline_text>.Str}</h2>\n");
  }

  method head3 ($/)
  {
    self.add_to_html('body', "<h3>{$/<singleline_text>.Str}</h3>\n");
  }

  method head4 ($/)
  {
    self.add_to_html('body', "<h4>{$/<singleline_text>.Str}</h4>\n");
  }

  method paragraph ($/ is copy) # required as regex writes to $/, and $/ is read only by default
  {
    my $para_text = $/<text>.Str.chomp;

    for %!buffer<paragraph>.reverse -> $pair # reverse as we're working outside in, replacing all formatting strings with their HTML
    {
      say "Processing key {$pair.key}";
      $para_text = $para_text.subst($pair.key, {$pair.value});
    }
    self.add_to_html('body', "<p>{$para_text}</p>\n");
    self.clear_buffer('paragraph');
  }

  method verbatim_paragraph ($/)
  {
    self.add_to_html('body', "<pre>{$/.Str}</pre>\n");
  }

  method begin_end ($/ is copy) # required as regex writes to $/, and $/ is read only by default
  {
    if $/<begin><name>.Str ~~ m:i/HTML/
    {
      self.add_to_html('body', "{$/<begin_end_content>.Str}\n");
    }
  }

  method for ($/ is copy) # required as regex writes to $/, and $/ is read only by default
  {
    if $/<name>.Str ~~ m:i/HTML/
    {
      self.add_to_html('body', "{$/<singleline_text>.Str}\n");
    }
  }

  method encoding ($/)
  {
    my $encoding = $/<name>.Str;

    if %.encoding_map{$encoding}:exists
    {
      $encoding = %.encoding_map{$encoding};
    }
    self.add_to_html('head', qq{<meta charset="$encoding">\n});
  }

  # formatting codes are added to a buffer which is used to replace
  # text in the parent paragraph
  method italic ($/)
  {
    self.add_to_buffer('paragraph', $/.Str => "<i>{$/<multiline_text>.Str}</i>");
  }

  method bold ($/)
  {
    self.add_to_buffer('paragraph', $/.Str => "<b>{$/<multiline_text>.Str}</b>");
  }

  method code ($/)
  {
    self.add_to_buffer('paragraph', $/.Str => "<code>{$/<multiline_text>.Str}</code>");
  }

  method escape ($/)
  {
    self.add_to_buffer('paragraph', $/.Str => "&{$/<singleline_format_text>.Str};");
  }

  # spec says to display in italics
  method filename ($/)
  {
    self.add_to_buffer('paragraph', $/.Str => "<i>{$/<singleline_format_text>.Str}</i>");
  }

  # singleline shouldn't break across lines, use <pre> to preserve the layout
  method singleline ($/)
  {
    self.add_to_buffer('paragraph', $/.Str => "<pre>{$/<singleline_format_text>.Str}</pre>");
  }

  # ignore index and zeroeffect
  method index ($/)
  {
    self.add_to_buffer('paragraph', $/.Str => "");
  }
  method zeroeffect ($/)
  {
    self.add_to_buffer('paragraph', $/.Str => "");
  }

  method link ($/ is copy) # required as regex writes to $/, and $/ is read only by default
  {
    my $original_string = $/.Str;
    my ($url, $text) = ("","");

    if $/<url>:exists and $/<singleline_format_text>:exists
    {
      $text = $/<singleline_format_text>.Str;
      $url  = $/<url>.Str;
    }
    elsif $/<url>:exists
    {
      $text = $/<url>.Str;
      $url  = $/<url>.Str;
    }
    elsif $/<singleline_format_text>:exists and $/<name>:exists and $/<section>:exists
    {
      $text = $/<singleline_format_text>.Str;
      $url  = "http://perldoc.perl.org/{$/<name>.Str}.html#{$/<section>.Str}";
    }
    elsif $/<name>:exists and $/<section>:exists
    {
      $text = "{$/<name>.Str}#{$<section>.Str}";
      $url  = "http://perldoc.perl.org/{$/<name>.Str}.html#{$/<section>.Str}";
    }
    elsif $/<name>:exists
    {
      $text = $/<name>.Str;
      $url  = "http://perldoc.perl.org/{$/<name>.Str}.html";
    }
    else #must just be a section on current doc
    {
      $text = $<section>.Str;
      $url  = "#{$/<section>.Str}";
    }

    # replace "::" with slash for the perldoc URLs
    if $url ~~ m/^https?\:\/\/perldoc\.perl\.org/
    {
      $url = $url.subst('::', {'/'}, :g);
    }
    self.add_to_buffer('paragraph', $original_string => qq|<a href="{$url}">{$text}</a>|);
  }

  # list handling
  method over ($/)
  {
    self.add_to_html('body', "<ul>\n");
  }

  method _item ($/)
  {
    self.add_to_html('body', "<li></li>\n");
  }

  method back ($/)
  {
    self.add_to_html('body', "</ul>\n");
  }
}

=begin pod

=head1 WARNING

This class is in development and subject to change

=head1 NAME

Pod::Perl5::ToHTML - an action class for C<Pod::Perl5::Grammar>, for converting pod to HTML

=head1 SYNOPSIS

  use Pod::Perl5::Grammar;
  use Pod::Perl5::ToHTML;

  # parse some pod to html
  my $to_html_action = Pod::Perl5::ToHTML.new;
  Pod::Perl5::Grammar.parse($some_pod_string, :actions($to_html_action));

=head1 METHODS

=head2 new (output_filehandle => $filehandle)

Creates a new C<Pod::Perl5::ToHTML> object. Optionally can take a filehandle argument, else
defaults to stdout

=cut

=end pod
