class Pod::Perl5::ToHTML
{
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
  has %!buffer = paragraph => Array.new();

  method get_buffer (Str:D $buffer_name) is rw
  {
    die ("buffer {$buffer_name} does not exist!") unless %!buffer{$buffer_name}:exists;
    return-rw %!buffer{$buffer_name}; # return-rw required, a naked "return" forces ro
  }

  method add_to_buffer (Str:D $buffer_name, Pair:D $pair)
  {
    self.get_buffer($buffer_name).push($pair);
  }

  method clear_buffer (Str:D $buffer_name)
  {
    self.get_buffer($buffer_name) = Array.new();
  }

  # once parsing is complete, this method is executed
  # we format and print the $html
  method TOP ($/)
  {
    $/.make: $<pod-section>».made;
  }

  method pod-section ($/)
  {
    # no list() elements?
    say $/.perl;

    my $pod;
    for $/.list.values -> $value
    {
      $pod ~= $value.made;
    }
    $/.make($pod);
  }

  multi method command-block:cut ($/) { $/.make('') }

  multi method command-block:head1 ($/)
  {
    $/.make("<h1>{$/<singleline_text>.Str}</h1>\n");
  }

  multi method command-block:head2 ($/)
  {
    $/.make("<h2>{$/<singleline_text>.Str}</h2>\n");
  }

  multi method command-block:head3 ($/)
  {
    $/.make("<h3>{$/<singleline_text>.Str}</h3>\n");
  }

  multi method command-block:head4 ($/)
  {
    $/.make("<h4>{$/<singleline_text>.Str}</h4>\n");
  }

  method paragraph ($match)
  {
    my $original_text = $match<paragraph_node>.join('').Str.chomp;
    my $para_text = $original_text;

    for self.get_buffer('paragraph').reverse -> $pair # reverse as we're working outside in, replacing all formatting strings with their HTML
    {
      $para_text = $para_text.subst($pair.key, {$pair.value});
    }
    $match.make("<p>{$para_text}</p>\n");
    self.clear_buffer('paragraph');
  }

  method verbatim_paragraph ($/)
  {
    $/.make("<pre>{$/.Str}</pre>\n");
  }

  multi method command-block:begin_end ($match)
  {
    if $match<begin><name>.Str.match(/^ HTML $/, :i)
    {
      $match.make("{$match<begin_end_content>.Str}\n");
    }
    else
    {
      $match.make('');
    }
  }

  multi method command-block:_for ($match)
  {
    if $match<name>.Str.match(/^ HTML $/, :i)
    {
      $match.make("{$match<singleline_text>.Str}\n");
    }
    else
    {
      $match.make('');
    }
  }

  multi method command-block:encoding ($/)
  {
    my $encoding = $/<name>.Str;

    if %.encoding_map{$encoding}:exists
    {
      $encoding = %.encoding_map{$encoding};
    }
    self.add_to_html('head', qq{<meta charset="$encoding">\n});
    $/.make('');
  }

  multi method format-code:italic ($/)
  {
    self.add_to_buffer('paragraph', $/.Str => "<i>{$/<multiline_text>.Str}</i>");
  }

  multi method format-code:bold ($/)
  {
    self.add_to_buffer('paragraph', $/.Str => "<b>{$/<multiline_text>.Str}</b>");
  }

  multi method format-code:code ($/)
  {
    self.add_to_buffer('paragraph', $/.Str => "<code>{$/<multiline_text>.Str}</code>");
  }

  multi method format-code:escape ($/)
  {
    self.add_to_buffer('paragraph', $/.Str => "&{$/<singleline_format_text>.Str};");
  }

  # spec says to display in italics
  multi method format-code:filename ($/)
  {
    self.add_to_buffer('paragraph', $/.Str => "<i>{$/<singleline_format_text>.Str}</i>");
  }

  # singleline shouldn't break across lines, use <pre> to preserve the layout
  multi method format-code:singleline ($/)
  {
    self.add_to_buffer('paragraph', $/.Str => "<pre>{$/<singleline_format_text>.Str}</pre>");
  }

  # ignore index and zeroeffect
  multi method format-code:index ($/)
  {
    self.add_to_buffer('paragraph', $/.Str => "");
  }
  multi method format-code:zeroeffect ($/)
  {
    self.add_to_buffer('paragraph', $/.Str => "");
  }

  multi method format-code:link ($match)
  {
    my $original_string = $match;
    my ($url, $text) = ("","");

    if $match<url>:exists and $match<singleline_format_text>:exists
    {
      $text = $match<singleline_format_text>.Str;
      $url  = $match<url>.Str;
    }
    elsif $match<url>:exists
    {
      $text = $match<url>.Str;
      $url  = $match<url>.Str;
    }
    elsif $match<singleline_format_text>:exists and $match<name>:exists and $match<section>:exists
    {
      $text = $match<singleline_format_text>.Str;
      $url  = "http://perldoc.perl.org/{$match<name>.Str}.html#{$match<section>.Str}";
    }
    elsif $match<name>:exists and $match<section>:exists
    {
      $text = "{$match<name>.Str}#{$match<section>.Str}";
      $url  = "http://perldoc.perl.org/{$match<name>.Str}.html#{$match<section>.Str}";
    }
    elsif $match<name>:exists
    {
      $text = $match<name>.Str;
      $url  = "http://perldoc.perl.org/{$match<name>.Str}.html";
    }
    else #must just be a section on current doc
    {
      $text = $<section>.Str;
      $url  = "#{$match<section>.Str}";
    }

    # replace "::" with slash for the perldoc URLs
    if $url ~~ m/^https?\:\/\/perldoc\.perl\.org/
    {
      $url = $url.subst('::', {'/'}, :g);
    }
    self.add_to_buffer('paragraph', $original_string => qq|<a href="{$url}">{$text}</a>|);
  }

  # ignoring ol for now
  multi method command-block:over_back ($/)
  {
    my $over_back = $/<over>.made;

    for $/[1].values -> $value
    {
      $over_back ~= $value.made;
    }
    $over_back ~= $/<back>.made;
    $/.make($over_back);
  }

  method over ($/)
  {
    $/.make('<ul>');
  }

  method _item ($/)
  {
    $/.make("<li>\n{$/<paragraph>.made}</li>\n");
  }

  method back ($/)
  {
    $/.make('</ul>');
  }

  method command-block:pod ($/) { $/.make('') }
  method blank_line        ($/) { $/.make('') }
}

