# PandocRuby

Wrapper for [Pandoc](http://johnmacfarlane.net/pandoc/), a Haskell library with command line tools for converting one markup format to another.

Pandoc can read markdown and (subsets of) reStructuredText, HTML, and LaTeX, and it can write markdown, reStructuredText, HTML, LaTeX, ConTeXt, PDF, RTF, DocBook XML, OpenDocument XML, ODT, GNU Texinfo, MediaWiki markup, groff man pages, and S5 HTML slide shows

## Installation

First, make sure to [install Pandoc](http://johnmacfarlane.net/pandoc/#installing-pandoc).

Next, install PandocRuby from gemcutter.

    gem install gemcutter
    gem tumble
    gem install pandoc-ruby
    
## Usage

    @converter = PandocRuby.new('/some/file.md', :from => :markdown, :to => :rst)
    puts @converter.convert

This takes the Markdown formatted file and converts it to reStructuredText. The first argument can be either a file or a string.

You can also use the `#convert` class method:

    puts PandocRuby.convert('/some/file.md', :from => :markdown, :to => :html)

When no options are passed, pandoc's default behavior converts markdown to html. To specify options, simply pass options as a hash to the initializer. Pandoc's wrapper executables can also be used by passing the executable name as the second argument. For example,

    PandocRuby.new('/some/file.html', 'html2markdown')

will use Pandoc's `html2markdown` wrapper.

Other arguments are simply converted into command line options, accepting symbols or strings for options without arguments and hashes of strings or symbols for options with arguments.

    PandocRuby.convert('/some/file.html', :s, {:to => :rst, :f => :markdown}, 'no-wrap')

becomes

    pandoc -s --to=rst -f markdown --no-wrap /some/file.html

PandocRuby assumes the pandoc executables are in the path.  If not, set their location
with `PandocRuby.bin_path = '/path/to/bin'`

For more information on Pandoc, see the [Pandoc documentation](http://johnmacfarlane.net/pandoc/) or run `man pandoc`.

Pretty much everything in the gem was derived directly from [Albino](http://github.com/github/albino).

## Caveats

* This has only been tested on *nix systems.
* Some conversions may still not work and/or require additional dependencies.

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
