class Pod::Perl5::ToHTML
{
  # default to stdout
  has $.output_filehandle = $*OUT;

  # this maps pod encoding values to their HTML equivalent
  # if no mapping is found, the pod encoding value will be
  # used
  has %.encoding_map is rw = utf8 => 'UTF-8';

  my ($head, $body);

  method add_to_head (Str:D $string)
  {
    $head = "<head>\n" unless $head;
    $head ~= "$string";
  }

  method add_to_body (Str:D $string)
  {
    $body = "<body>" unless $body;
    $body ~= "$string";
  }

  method TOP ($/)
  {
    say $.output_filehandle, qq:to/END/;
      <html>
      { if ($head) { $head ~ '</head>' } }
      { if ($body) { $body ~ '</body>' } }
      </html>
      END
  }

  method head1 ($/)
  {
    self.add_to_body("<h1>{$/<singleline_text>.Str}</h1>\n");
  }

  method head2 ($/)
  {
    self.add_to_body("<h2>{$/<singleline_text>.Str}</h2>\n");
  }

  method head3 ($/)
  {
    self.add_to_body("<h3>{$/<singleline_text>.Str}</h3>\n");
  }

  method head4 ($/)
  {
    self.add_to_body("<h4>{$/<singleline_text>.Str}</h4>\n");
  }

  method paragraph ($/)
  {
    self.add_to_body("<p>{$/<text>.Str.chomp}</p>\n");
  }

  method verbatim_paragraph ($/)
  {
    self.add_to_body("<pre>{$/.Str}</pre>\n");
  }

  method begin_end ($/)
  {
    # 2015.04-51-g0c197cd error "cannot assign to a readonly variable"
    #if $/<begin><name>.Str ~~ m:i/HTML/
    {
      self.add_to_body("{$/<begin_end_content>.Str}\n");
    }
  }

  method encoding ($/)
  {
    my $encoding = $/<name>.Str;

    if %.encoding_map<$encoding>:exists
    {
      $encoding = %.encoding_map<$encoding>;
    }
    self.add_to_head(qq{<meta charset="$encoding">\n});
  }
}

=begin pod

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
