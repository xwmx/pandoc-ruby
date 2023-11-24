require 'helper'

describe PandocRuby do
  before do
    @file       = File.join(File.dirname(__FILE__), 'files', 'Test File 1.md')
    @file2      = File.join(File.dirname(__FILE__), 'files', 'Test File 2.md')
    @string     = '# Test String'
    @converter  = PandocRuby.new(@string, :t => :rst)
  end

  after do
    PandocRuby.pandoc_path = 'pandoc'
  end

  it 'calls bare pandoc when passed no options' do
    converter = PandocRuby.new(@string)

    converter.expects(:execute).with('pandoc').returns(true)

    assert converter.convert
  end

  it 'converts with altered pandoc_path' do
    path = '/usr/bin/env pandoc'
    PandocRuby.pandoc_path = path

    converter = PandocRuby.new(@string)

    converter.expects(:execute).with(path).returns(true)

    assert converter.convert
  end

  it 'converts input passed as a string' do
    assert_equal "<h1 id=\"test-string\">Test String</h1>\n",
                 PandocRuby.new(@string).to_html
  end

  it 'converts single element array input as array of file paths' do
    assert PandocRuby.new([@file]).to_html.match(/This is a Title/)
  end

  it 'converts multiple element array input as array of file paths' do
    assert PandocRuby.new([@file, @file2]).to_html.match(/This is a Title/)
    assert PandocRuby.new([@file, @file2]).to_html.match(/A Second Title/)
  end

  it 'converts multiple element array input as array of file paths to a binary output format' do
    assert PandocRuby.new([@file, @file2]).to_epub.match(/com.apple.ibooks/)
  end

  it 'accepts short options' do
    @converter.expects(:execute).with('pandoc -t "rst"').returns(true)

    assert @converter.convert
  end

  it 'accepts long options' do
    converter = PandocRuby.new(@string, :to => :rst)

    converter.expects(:execute).with('pandoc --to "rst"').returns(true)

    assert converter.convert
  end

  it 'accepts a variety of options in initializer' do
    converter = PandocRuby.new(
      @string,
      :s,
      { :f => :markdown, :to => :rst },
      'no-wrap'
    )

    converter                                               \
      .expects(:execute)                                    \
      .with('pandoc -s -f "markdown" --to "rst" --no-wrap') \
      .returns(true)

    assert converter.convert
  end

  it 'accepts a variety of options in convert' do
    converter = PandocRuby.new(@string)

    converter                                               \
      .expects(:execute)                                    \
      .with('pandoc -s -f "markdown" --to "rst" --no-wrap') \
      .returns(true)

    assert converter.convert(:s, { :f => :markdown, :to => :rst }, 'no-wrap')
  end

  it 'converts underscore symbol args to hyphenated long options' do
    converter = PandocRuby.new(
      @string,
      { :email_obfuscation => :javascript },
      :table_of_contents
    )

    converter                                                               \
      .expects(:execute)                                                    \
      .with('pandoc --email-obfuscation "javascript" --table-of-contents')  \
      .returns(true)

    assert converter.convert
  end

  it 'uses second arg as option' do
    converter = PandocRuby.new(@string, 'toc')

    converter.expects(:execute).with('pandoc --toc').returns(true)

    assert converter.convert
  end

  it 'passes command line options without modification' do
    converter = PandocRuby.new(
      @string,
      '+RTS', '-M512M', '-RTS', '--to=markdown', '--no-wrap'
    )

    converter.expects(:execute).with(
      'pandoc +RTS -M512M -RTS --to=markdown --no-wrap'
    ).returns(true)

    assert converter.convert
  end

  it 'supports reader extensions' do
    assert_equal(
      PandocRuby.convert(
        "Line 1\n# Heading",
        :from => 'markdown_strict',
        :to   => 'html'
      ),
      "<p>Line 1</p>\n<h1>Heading</h1>\n"
    )

    assert_equal(
      PandocRuby.convert(
        "Line 1\n# Heading",
        :from => 'markdown_strict+blank_before_header',
        :to   => 'html'
      ),
      "<p>Line 1 # Heading</p>\n"
    )
  end

  it 'supports writer extensions' do
    assert_equal(
      PandocRuby.convert(
        "<sub>example</sub>\n",
        :from => 'html',
        :to   => 'markdown'
      ),
      "~example~\n"
    )

    assert_equal(
      PandocRuby.convert(
        "<sub>example</sub>\n",
        :from => 'html',
        :to   => 'markdown-subscript'
      ),
      "<sub>example</sub>\n"
    )
  end

  it 'supports output filenames without spaces' do
    Tempfile.create('example') do |file|
      PandocRuby.convert(
        '# Example',
        :from   => 'markdown',
        :to     => 'html',
        :output => file.path
      )

      file.rewind

      assert_equal("<h1 id=\"example\">Example</h1>\n", file.read)
    end
  end

  it 'quotes output filenames with spaces' do
    Tempfile.create('example with spaces') do |file|
      converter = PandocRuby.new(
        '# Example',
        :from   => 'markdown',
        :to     => 'html',
        :output => file.path
      )

      converter             \
        .expects(:execute)  \
        .with(
          "pandoc --from \"markdown\" --to \"html\" --output \"#{file.path}\""
        ).returns(true)

      assert converter.convert
    end
  end

  it 'outputs to filenames with spaces' do
    Tempfile.create('example with spaces') do |file|
      PandocRuby.convert(
        '# Example',
        :from   => 'markdown',
        :to     => 'html',
        :output => file.path
      )

      file.rewind

      assert_equal("<h1 id=\"example\">Example</h1>\n", file.read)
    end
  end

  it 'quotes output filenames as Pathname objects' do
    Tempfile.create('example with spaces') do |file|
      converter = PandocRuby.new(
        '# Example',
        :from   => 'markdown',
        :to     => 'html',
        :output => Pathname.new(file.path)
      )

      converter             \
        .expects(:execute)  \
        .with(
          "pandoc --from \"markdown\" --to \"html\" --output \"#{file.path}\""
        ).returns(true)

      assert converter.convert
    end
  end

  it 'outputs to filenames as Pathname objects' do
    Tempfile.create('example with spaces') do |file|
      PandocRuby.convert(
        '# Example',
        :from   => 'markdown',
        :to     => 'html',
        :output => Pathname.new(file.path)
      )

      file.rewind

      assert_equal("<h1 id=\"example\">Example</h1>\n", file.read)
    end
  end

  it 'raises RuntimeError from pandoc executable error' do
    assert_raises(RuntimeError) do
      PandocRuby.new('# hello', 'badopt').to_html5
    end
  end

  PandocRuby::READERS.each_key do |r|
    it "converts from #{r} with PandocRuby.#{r}" do
      converter = PandocRuby.send(r, @string)

      converter.expects(:execute).with("pandoc --from \"#{r}\"").returns(true)

      assert converter.convert
    end
  end

  PandocRuby::STRING_WRITERS.each_key do |w|
    it "converts to #{w} with to_#{w}" do
      converter = PandocRuby.new(@string)

      converter                                 \
        .expects(:execute)                      \
        .with("pandoc --no-wrap --to \"#{w}\"") \
        .returns(true)

      assert converter.send("to_#{w}", :no_wrap)
    end
  end

  PandocRuby::BINARY_WRITERS.each_key do |w|
    it "converts to #{w} with to_#{w}" do
      converter = PandocRuby.new(@string)

      converter                                                           \
        .expects(:execute)                                                \
        .with(regexp_matches(/^pandoc --no-wrap --to "#{w}" --output /))  \
        .returns(true)

      assert converter.send("to_#{w}", :no_wrap)
    end
  end

  it 'works with strings' do
    converter = PandocRuby.new('## this is a title')

    assert_match(/h2/, converter.convert)
  end

  it 'accepts blank strings' do
    converter = PandocRuby.new('')

    assert_match("\n", converter.convert)
  end

  it 'accepts nil and treats like a blank string' do
    converter = PandocRuby.new(nil)

    assert_match("\n", converter.convert)
  end

  it 'aliases to_s' do
    assert_equal @converter.convert, @converter.to_s
  end

  it 'has convert class method' do
    assert_equal @converter.convert, PandocRuby.convert(@string, :t => :rst)
  end

  it 'runs more than 400 times without error' do
    begin
      400.times do
        PandocRuby.convert(@string)
      end

      assert true
    rescue Errno::EMFILE, Errno::EAGAIN => e
      flunk e
    end
  end

  it 'gracefully times out when pandoc hangs due to malformed input' do
    skip('Pandoc no longer times out with test file. Determine how to test.')

    file = File.join(File.dirname(__FILE__), 'files', 'bomb.tex')

    contents = File.read(file)

    assert_raises(RuntimeError) do
      PandocRuby.convert(
        contents, :from => :latex, :to => :html, :timeout => 1
      )
    end
  end

  it 'has reader and writer constants' do
    assert_equal(
      PandocRuby::READERS,
      'biblatex'          => 'BibLaTeX bibliography',
      'bibtex'            => 'BibTeX bibliography',
      'commonmark'        => 'CommonMark Markdown',
      'commonmark_x'      => 'CommonMark Markdown with extensions',
      'creole'            => 'Creole 1.0',
      'csljson'           => 'CSL JSON bibliography',
      'csv'               => 'CSV table',
      'docbook'           => 'DocBook',
      'docx'              => 'Word docx',
      'dokuwiki'          => 'DokuWiki markup',
      'endnotexml'        => 'EndNote XML bibliography',
      'epub'              => 'EPUB',
      'fb2'               => 'FictionBook2 e-book',
      'gfm'               => 'GitHub-Flavored Markdown',
      'haddock'           => 'Haddock markup',
      'html'              => 'HTML',
      'ipynb'             => 'Jupyter notebook',
      'jats'              => 'JATS XML',
      'jira'              => 'Jira wiki markup',
      'json'              => 'JSON version of native AST',
      'latex'             => 'LaTex',
      'man'               => 'roff man',
      'markdown'          => "Pandoc's Markdown",
      'markdown_mmd'      => 'MultiMarkdown',
      'markdown_phpextra' => 'PHP Markdown Extra',
      'markdown_strict'   => 'original unextended Markdown',
      'mediawiki'         => 'MediaWiki markup',
      'muse'              => 'Muse',
      'native'            => 'native Haskell',
      'odt'               => 'ODT',
      'opml'              => 'OPML',
      'org'               => 'Emacs Org mode',
      'ris'               => 'RIS bibliography',
      'rst'               => 'reStructuredText',
      'rtf'               => 'Rich Text Format',
      't2t'               => 'txt2tags',
      'textile'           => 'Textile',
      'tikiwiki'          => 'TikiWiki markup',
      'tsv'               => 'TSV table',
      'twiki'             => 'TWiki markup',
      'vimwiki'           => 'Vimwiki'
    )

    assert_equal(
      PandocRuby::STRING_WRITERS,
      'asciidoc'              => 'AsciiDoc',
      'asciidoctor'           => 'AsciiDoctor',
      'beamer'                => 'LaTeX beamer slide show',
      'biblatex'              => 'BibLaTeX bibliography',
      'bibtex'                => 'BibTeX bibliography',
      'chunkedhtml'           => 'zip archive of multiple linked HTML files',
      'commonmark'            => 'CommonMark Markdown',
      'commonmark_x'          => 'CommonMark Markdown with extensions',
      'context'               => 'ConTeXt',
      'csljson'               => 'CSL JSON bibliography',
      'docbook'               => 'DocBook 4',
      'docbook4'              => 'DocBook 4',
      'docbook5'              => 'DocBook 5',
      'dokuwiki'              => 'DokuWiki markup',
      'fb2'                   => 'FictionBook2 e-book',
      'gfm'                   => 'GitHub-Flavored Markdown',
      'haddock'               => 'Haddock markup',
      'html'                  => 'HTML, i.e.  HTML5/XHTML polyglot markup',
      'html5'                 => 'HTML, i.e.  HTML5/XHTML polyglot markup',
      'html4'                 => 'XHTML 1.0 Transitional',
      'icml'                  => 'InDesign ICML',
      'ipynb'                 => 'Jupyter notebook',
      'jats_archiving'        => 'JATS XML, Archiving and Interchange Tag Set',
      'jats_articleauthoring' => 'JATS XML, Article Authoring Tag Set',
      'jats_publishing'       => 'JATS XML, Journal Publishing Tag Set',
      'jats'                  => 'alias for jats_archiving',
      'jira'                  => 'Jira wiki markup',
      'json'                  => 'JSON version of native AST',
      'latex'                 => 'LaTex',
      'man'                   => 'roff man',
      'markdown'              => "Pandoc's Markdown",
      'markdown_mmd'          => 'MultiMarkdown',
      'markdown_phpextra'     => 'PHP Markdown Extra',
      'markdown_strict'       => 'original unextended Markdown',
      'markua'                => 'Markua',
      'mediawiki'             => 'MediaWiki markup',
      'ms'                    => 'roff ms',
      'muse'                  => 'Muse',
      'native'                => 'native Haskell',
      'opml'                  => 'OPML',
      'opendocument'          => 'OpenDocument',
      'org'                   => 'Emacs Org mode',
      'pdf'                   => 'PDF',
      'plain'                 => 'plain text',
      'pptx'                  => 'PowerPoint slide show',
      'rst'                   => 'reStructuredText',
      'rtf'                   => 'Rich Text Format',
      'texinfo'               => 'GNU Texinfo',
      'textile'               => 'Textile',
      'slideous'              => 'Slideous HTML and JavaScript slide show',
      'slidy'                 => 'Slidy HTML and JavaScript slide show',
      'dzslides'              => 'DZSlides HTML5 + JavaScript slide show',
      'revealjs'              => 'reveal.js HTML5 + JavaScript slide show',
      's5'                    => 'S5 HTML and JavaScript slide show',
      'tei'                   => 'TEI Simple',
      'xwiki'                 => 'XWiki markup',
      'zimwiki'               => 'ZimWiki markup'
    )

    assert_equal(
      PandocRuby::BINARY_WRITERS,
      'odt'   => 'OpenOffice text document',
      'docx'  => 'Word docx',
      'epub'  => 'EPUB v3',
      'epub2' => 'EPUB v2',
      'epub3' => 'EPUB v3'
    )

    assert_equal(
      PandocRuby::WRITERS,
      PandocRuby::STRING_WRITERS.merge(PandocRuby::BINARY_WRITERS)
    )
  end
end
