class Pod::Perl5::ToHTML
{
  # meta directives like encoding
  has $!meta;

  sub stringify-match ($match)
  {
    my $pod = '';
    for $match.caps -> $value
    {
      $pod ~= $value.value.made;
    }
    return $pod;
  }

  method TOP ($match)
  {
    my $head = $!meta ?? "\n<head>{$!meta}\n</head>" !! '';
    my $body = "\n<body>{stringify-match($match)}\n</body>";
    $match.make("<html>{$head}{$body}\n</html>\n");
  }

  method pod-section ($match)
  {
    $match.make(stringify-match($match));
  }

  #######################
  # Text
  #######################
  method verbatim-paragraph ($match)
  {
    my ($leading_space, $text);

    for $match.caps -> $pair
    {
      my $line = $pair.value;
      unless ($leading_space.defined)
      {
        $line ~~ /^$<leading_space>=[\h+]/;
        $leading_space = $<leading_space>.Str;
      }
      $text ~= $line.subst(/^$leading_space/, '');
    }
    $match.make("\n<pre>{$text}</pre>");
  }

  method paragraph ($match)
  {
    $match.make("\n<p>{$match<multiline-text>.made}</p>");
  }

  method any-text        ($match) { $match.make($match.Str) }
  method no-vertical     ($match) { $match.make($match.Str) }
  method blank-line      ($match) { $match.make("\n")       }
  method name            ($match) { $match.make($match.Str) }
  method singleline-text ($match) { $match.make($match.Str) }
  method singleline-format-text
                         ($match) { $match.make($match.Str) }

  method format-text ($match)
  {
    $match.make(stringify-match($match));
  }

  method multiline-text ($match)
  {
    $match.make(stringify-match($match));
  }

  method section ($match) { $match.make($match.Str) }

  ########################
  # command blocks
  ########################
  method cut ($match) { $match.make('') }

  multi method command-block:head1 ($match)
  {
    $match.make("\n<h1>{$match<singleline-text>.made}</h1>");
  }

  multi method command-block:head2 ($match)
  {
    $match.make("\n<h2>{$match<singleline-text>.made}</h2>");
  }

  multi method command-block:head3 ($match)
  {
    $match.make("\n<h3>{$match<singleline-text>.made}</h3>");
  }

  multi method command-block:head4 ($match)
  {
    $match.make("\n<h4>{$match<singleline-text>.made}</h4>");
  }

  multi method command-block:begin-end ($match)
  {
    if $match<begin><name>.made.match(/^ HTML $/, :i)
    {
      $match.make("\n{$match<begin-end-content>.Str}");
    }
    else
    {
      $match.make('');
    }
  }

  multi method begin-end-content ($match) { $match.make('') }
  multi method begin             ($match) { $match.make('') }
  multi method _end              ($match) { $match.make('') }

  multi method command-block:_for ($match)
  {
    if $match<name>.made.match(/^ HTML $/, :i)
    {
      $match.make("\n{$match<singleline-text>.made}");
    }
    else
    {
      $match.make('');
    }
  }

  multi method command-block:encoding ($match)
  {
    # "utf8" is a common Pod encoding, it should be UTF-8 in HTML
    my $pod_encoding = $match<name>.made;
    my $html_encoding = $pod_encoding eq 'utf8' ?? 'UTF-8' !! $pod_encoding;

    # save in meta to be used in <head> later
    $!meta ~= qq/\n<meta charset="$html_encoding">/;

    # make an empty string so the encoding is not returned inline
    $match.make('');
  }

  multi method command-block:over-back ($match)
  {
    # peak at the first bullet point to decide if it's
    # an ordered or unordered list
    if ($match<_item>:exists
        && $match<_item>[0]<bullet-point>.Str ~~ /^<[0..9]>+$/)
    {
      $match.make("\n<ol>{ stringify-match($match) }\n</ol>");
    }
    else
    {
      $match.make("\n<ul>{ stringify-match($match) }\n</ul>");
    }
  }

  method over ($match)         { $match.make('') }
  method back ($match)         { $match.make('') }
  method bullet-point ($match) { $match.make('') }

  method _item ($match)
  {
    $match.make("\n<li>{ $match.make(stringify-match($match)) }</li>");
  }


  method command-block:pod ($match) { $match.make('') }

  ########################
  # formatting codes
  ########################
  multi method format-code:italic ($match)
  {
    $match.make("<em>{$match<format-text>.made}</em>");
  }

  multi method format-code:bold ($match)
  {
    $match.make("<strong>{$match<format-text>.made}</strong>");
  }

  multi method format-code:code ($match)
  {
    $match.make("<code>{$match<format-text>.made}</code>");
  }

  # html encode this
  multi method format-code:escape ($match)
  {
    $match.make("&{$match<format-text>.made};");
  }

  # spec says to display in italics
  multi method format-code:filename ($match)
  {
    $match.make("<em>{$match<format-text>.made}</em>");
  }

  # singleline shouldn't break across lines ...
  multi method format-code:singleline ($match)
  {
    $match.make("<pre>{$match<format-text>.made}</pre>");
  }

  # perlpod says index should be an empty string
  multi method format-code:index ($match)
  {
    $match.make('');
  }

  # literally capture any text between zeroeffect
  multi method format-code:zeroeffect ($match)
  {
    $match.make($match<format-text>.Str);
  }

  multi method format-code:link ($match)
  {
    my ($url, $text) = ("","");

    if $match<url>:exists and $match<singleline-format-text>:exists
    {
      $text = $match<singleline-format-text>.made;
      $url  = $match<url>.made;
    }
    elsif $match<url>:exists
    {
      $text = $match<url>.made;
      $url  = $match<url>.made;
    }
    elsif $match<singleline-format-text>:exists and $match<name>:exists and $match<section>:exists
    {
      $text = $match<singleline-format-text>.made;
      $url  = "http://perldoc.perl.org/{$match<name>.made}.html#{$match<section>.made}";
    }
    elsif $match<name>:exists and $match<section>:exists
    {
      $text = "{$match<name>.made}#{$match<section>.made}";
      $url  = "http://perldoc.perl.org/{$match<name>.made}.html#{$match<section>.made}";
    }
    elsif $match<name>:exists
    {
      $text = $match<name>.made;
      $url  = "http://perldoc.perl.org/{$match<name>.made}.html";
    }
    else #must just be a section on current doc
    {
      $text = $<section>.made;
      $url  = "#{$match<section>.made}";
    }

    # replace "::" with slash for the perldoc URLs
    if $url ~~ m/^https?\:\/\/perldoc\.perl\.org/
    {
      $url = $url.subst('::', {'/'}, :g);
    }
    $match.make(qq|<a href="{$url}">{$text}</a>|);
  }

  method url ($match)
  {
    $match.make($match.Str);
  }
}

# vim: filetype=perl6
