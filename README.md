# PandocRuby

PandocRuby is a wrapper for [Pandoc](http://johnmacfarlane.net/pandoc/), a
Haskell library with command line tools for converting one markup format to
another.

Pandoc can convert documents in markdown, reStructuredText, textile, HTML,
DocBook, LaTeX, or MediaWiki markup to a variety of formats, including
markdown, reStructuredText, HTML, LaTeX, ConTeXt, PDF, RTF, DocBook XML,
OpenDocument XML, ODT, GNU Texinfo, MediaWiki markup, groff man pages,
HTML slide shows, EPUB, and Microsoft Word docx.

## Installation

First, make sure to
[install Pandoc](http://johnmacfarlane.net/pandoc/installing.html).

Next, add PandocRuby to your Gemfile

```ruby
gem 'pandoc-ruby'
```

or install PandocRuby from [RubyGems](http://rubygems.org/gems/pandoc-ruby).

```bash
gem install pandoc-ruby
```

## Usage

```ruby
require 'pandoc-ruby'
@converter = PandocRuby.new('# Markdown Title', from: :markdown, to: :rst)
puts @converter.convert
```

This takes the Markdown formatted file and converts it to reStructuredText.

You can also use the `#convert` class method:

```ruby
puts PandocRuby.convert('# Markdown Title', from: :markdown, to: :html)
```

Other arguments are simply converted into command line options, accepting
symbols or strings for options without arguments and hashes of strings or
symbols for options with arguments.

```ruby
PandocRuby.convert('# Markdown Title', :s, {f: :markdown, to: :rst}, 'no-wrap', :table_of_contents)
```

is equivalent to

```bash
echo "# Markdown Title" | pandoc -s -f markdown --to=rst --no-wrap --table-of-contents
```

Also provided are `#to_[writer]` instance methods for each of the writers,
and these can also accept options:

```ruby
PandocRuby.new("# Some title").to_html(:no_wrap)
# => "<div id=\"some-title\"><h1>Some title</h1></div>"
# or
PandocRuby.new("# Some title").to_rst
# => "Some title\n=========="
```

Similarly, there are class methods for each of the readers, so readers
and writers can be specified like this:

```ruby
PandocRuby.html("<h1>hello</h1>").to_latex
# => "\\section{hello}"
```

PandocRuby assumes the `pandoc` executable is via your environment's `$PATH`
variable.  If you'd like to set an explicit path to the `pandoc` executable,
you can do so with  `PandocRuby.pandoc_path = '/path/to/pandoc'`

### Converting Files

PandocRuby can also take an array of one or more file paths as the first
argument. The files will be concatenated together with a blank line between
each and used as input.

```ruby
# One file path as a single-element array.
PandocRuby.new(['/path/to/file1.docx'], from: 'docx').to_html
# Multiple file paths as an array.
PandocRuby.new(['/path/to/file1.docx', '/path/to/file1.docx'], from: 'docx').to_html
```

If you are trying to generate a standalone file with full file headers rather
than just a marked up fragment, remember to pass the `:standalone` option so
the correct header and footer are added.

```ruby
PandocRuby.new("# Some title", :standalone).to_rtf
```

### Extensions

Pandoc [extensions](https://pandoc.org/MANUAL.html#extensions) can be
used to modify the behavior of readers and writers. To use an extension,
add the extension with a `+` or `-` after the reader or writer name:

```ruby
# Without extension
PandocRuby.new("Line 1\n# Heading", from: 'markdown_strict').to_html
# => "<p>Line 1</p>\n<h1>Heading</h1>\n"

# With extension:
>> PandocRuby.new("Line 1\n# Heading", from: 'markdown_strict+blank_before_header').to_html
# => "<p>Line 1 # Heading</p>\n
```

### More Information

Available format readers and writers are available in the `PandocRuby::READERS`
and `PandocRuby::WRITERS` constants.

For more information on Pandoc, see the
[Pandoc documentation](http://johnmacfarlane.net/pandoc/)
or run `man pandoc`
([also available here](http://johnmacfarlane.net/pandoc/pandoc.1.html)).

If you'd prefer a pure-Ruby extended markdown interpreter that can output a
few different formats, take a look at
[kramdown](https://kramdown.gettalong.org/). If you want to use the full
reStructuredText syntax from within Ruby, check out
[RbST](https://github.com/xwmx/rbst), a docutils wrapper.

This gem was inspired by [Albino](http://github.com/github/albino). For a
slightly different approach to using Pandoc with Ruby, see
[Pandoku](http://github.com/dahlia/pandoku).

## Note on Patches/Pull Requests

* Fork the project.
* Make your feature addition or bug fix.
* Add tests for it. This is important so I don't break it in a
  future version unintentionally.
* Commit, do not mess with rakefile, version, or history.
  (if you want to have your own version, that is fine but
  bump version in a commit by itself I can ignore when I pull)
* Send me a pull request. Bonus points for topic branches.
