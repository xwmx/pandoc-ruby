# PandocRuby

Wrapper for [Pandoc](http://johnmacfarlane.net/pandoc/), a Haskell library with command line tools for converting one markup format to another.

Pandoc can read markdown and (subsets of) reStructuredText, HTML, and LaTeX, and it can write markdown, reStructuredText, HTML, LaTeX, ConTeXt, PDF, RTF, DocBook XML, OpenDocument XML, ODT, GNU Texinfo, MediaWiki markup, groff man pages, and S5 HTML slide shows

## Installation

First, make sure to [install Pandoc](http://johnmacfarlane.net/pandoc/#installing-pandoc).

Next, install PandocRuby from [gemcutter](http://gemcutter.org/gems/pandoc-ruby).

    gem install pandoc-ruby

## Usage

    require 'pandoc-ruby'
    @converter = PandocRuby.new('# Markdown Title', :from => :markdown, :to => :rst)
    puts @converter.convert

This takes the Markdown formatted file and converts it to reStructuredText.

You can also use the `#convert` class method:

    puts PandocRuby.convert('# Markdown Title', :from => :markdown, :to => :html)

When no options are passed, pandoc's default behavior converts markdown to html. To specify options, simply pass options as a hash to the initializer. Pandoc's wrapper executables can also be used by passing the executable name as the second argument. For example,

    PandocRuby.new('<p>Some <em>HTML</em></p>', 'html2markdown')

will use Pandoc's `html2markdown` wrapper.

Other arguments are simply converted into command line options, accepting symbols or strings for options without arguments and hashes of strings or symbols for options with arguments.

    PandocRuby.convert('# Markdown Title', :s, {:f => :markdown, :to => :rst}, 'no-wrap', :table_of_contents)

is equivalent to

    echo "# Markdown Title" | pandoc -s -f markdown --to=rst --no-wrap --table-of-contents

Also provided are `#to_[writer]` instance methods for each of the writers, and these can also accept options:

    PandocRuby.new("# Some title").to_html(:no_wrap)
    => "<div id=\"some-title\"><h1>Some title</h1></div>"
    # or
    PandocRuby.new("# Some title").to_rst
    => "Some title\n=========="

Similarly, there are class methods for each of the readers, so readers and writers can be specified like this:

    PandocRuby.html("<h1>hello</h1>").to_latex
    => "\\section{hello}"

PandocRuby assumes the pandoc executables are in the path.  If not, set their location
with `PandocRuby.bin_path = '/path/to/bin'`

Pandoc can also be set to take a file path as the first argument. For security reasons, this is disabled by default, but it can be enabled and used as follows

    PandocRuby.allow_file_paths = true
    PandocRuby.html('/some/file.html').to_markdown

Available format readers and writers are available in the `PandocRuby::READERS` and `PandocRuby::WRITERS` constants.

For more information on Pandoc, see the [Pandoc documentation](http://johnmacfarlane.net/pandoc/) or run `man pandoc` ([also available here](http://johnmacfarlane.net/pandoc/pandoc.1.html)).

If you'd prefer a pure-Ruby extended markdown interpreter that can output a few different formats, take a look at [Maruku](http://maruku.rubyforge.org/). If you want to use the full reStructuredText syntax from within Ruby, check out [RbST](http://rdoc.info/projects/autodata/rbst), a docutils wrapper.

This gem was inspired by [Albino](http://github.com/github/albino). For a slightly different approach to using Pandoc with Ruby, see [Pandoku](http://github.com/dahlia/pandoku).

## Pandoc Hint

If you are trying to generate a standalone file with full file headers rather than just a marked up fragment, remember to pass the `:standalone` option so the correct header and footer are added.

    PandocRuby.new("# Some title", :standalone).to_rtf

## Caveats

* This has only been tested on \*nix systems.
* ODT is not currently supported because it is a binary format.
* PDF conversion may require additional dependencies and has not been tested.

## Note on Patches/Pull Requests
 
* Fork the project.
* Make your feature addition or bug fix.
* Add tests for it. This is important so I don't break it in a
  future version unintentionally.
* Commit, do not mess with rakefile, version, or history.
  (if you want to have your own version, that is fine but
  bump version in a commit by itself I can ignore when I pull)
* Send me a pull request. Bonus points for topic branches.

## Copyright

Copyright (c) 2009 William Melody. See LICENSE for details.
