require 'helper'

describe PandocRuby do
  before do
    @file = File.join(File.dirname(__FILE__), 'files', 'test.md')
    @file2 = File.join(File.dirname(__FILE__), 'files', 'test2.md')
    @string = '# Test String'
    @converter = PandocRuby.new(@string, :t => :rst)
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
    @converter.expects(:execute).with('pandoc -t rst').returns(true)
    assert @converter.convert
  end

  it 'accepts long options' do
    converter = PandocRuby.new(@string, :to => :rst)
    converter.expects(:execute).with('pandoc --to rst').returns(true)
    assert converter.convert
  end

  it 'accepts a variety of options in initializer' do
    converter = PandocRuby.new(@string, :s, {
      :f => :markdown, :to => :rst
    }, 'no-wrap')
    converter \
      .expects(:execute) \
      .with('pandoc -s -f markdown --to rst --no-wrap') \
      .returns(true)
    assert converter.convert
  end

  it 'accepts a variety of options in convert' do
    converter = PandocRuby.new(@string)
    converter \
      .expects(:execute) \
      .with('pandoc -s -f markdown --to rst --no-wrap') \
      .returns(true)
    assert converter.convert(:s, { :f => :markdown, :to => :rst }, 'no-wrap')
  end

  it 'converts underscore symbol ares to hyphenated long options' do
    converter = PandocRuby.new(@string, {
      :email_obfuscation => :javascript
    }, :table_of_contents)
    converter \
      .expects(:execute) \
      .with('pandoc --email-obfuscation javascript --table-of-contents') \
      .returns(true)
    assert converter.convert
  end

  it 'uses second arg as option' do
    converter = PandocRuby.new(@string, 'toc')
    converter.expects(:execute).with('pandoc --toc').returns(true)
    assert converter.convert
  end

  it 'raises RuntimeError from pandoc executable error' do
    assert_raises(RuntimeError) do
      PandocRuby.new('# hello', 'badopt').to_html5
    end
  end

  PandocRuby::READERS.each_key do |r|
    it "converts from #{r} with PandocRuby.#{r}" do
      converter = PandocRuby.send(r, @string)
      converter.expects(:execute).with("pandoc --from #{r}").returns(true)
      assert converter.convert
    end
  end

  PandocRuby::STRING_WRITERS.each_key do |w|
    it "converts to #{w} with to_#{w}" do
      converter = PandocRuby.new(@string)
      converter \
        .expects(:execute) \
        .with("pandoc --no-wrap --to #{w}") \
        .returns(true)
      assert converter.send("to_#{w}", :no_wrap)
    end
  end

  PandocRuby::BINARY_WRITERS.each_key do |w|
    it "converts to #{w} with to_#{w}" do
      converter = PandocRuby.new(@string)
      converter \
        .expects(:execute) \
        .with(regexp_matches(/^pandoc --no-wrap --to #{w} --output /)) \
        .returns(true)
      assert converter.send("to_#{w}", :no_wrap)
    end
  end

  it 'works with strings' do
    converter = PandocRuby.new('## this is a title')
    assert_match(/h2/, converter.convert)
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
    file = File.join(File.dirname(__FILE__), 'files', 'bomb.tex')
    contents = File.read(file)

    assert_raises(RuntimeError) do
      PandocRuby.convert(
        contents, :from => :latex, :to => :html, :timeout => 1
      )
    end
  end

  it 'has reader and writer constants' do
    assert_equal PandocRuby::READERS,
                 'html'      =>  'HTML',
                 'latex'     =>  'LaTeX',
                 'textile'   =>  'textile',
                 'native'    =>  'pandoc native',
                 'markdown'  =>  'markdown',
                 'json'      =>  'pandoc JSON',
                 'rst'       =>  'reStructuredText'

    assert_equal PandocRuby::STRING_WRITERS,
                 'mediawiki'     =>  'MediaWiki markup',
                 'html'          =>  'HTML',
                 'plain'         =>  'plain',
                 'latex'         =>  'LaTeX',
                 's5'            =>  'S5 HTML slideshow',
                 'textile'       =>  'textile',
                 'texinfo'       =>  'GNU Texinfo',
                 'docbook'       =>  'DocBook XML',
                 'html5'         =>  'HTML5',
                 'native'        =>  'pandoc native',
                 'org'           =>  'emacs org mode',
                 'rtf'           =>  'rich text format',
                 'markdown'      =>  'markdown',
                 'man'           =>  'groff man',
                 'dzslides'      =>  'Dzslides HTML slideshow',
                 'beamer'        =>  'Beamer PDF slideshow',
                 'json'          =>  'pandoc JSON',
                 'opendocument'  =>  'OpenDocument XML',
                 'slidy'         =>  'Slidy HTML slideshow',
                 'rst'           =>  'reStructuredText',
                 'context'       =>  'ConTeXt',
                 'asciidoc'      =>  'asciidoc'

    assert_equal PandocRuby::BINARY_WRITERS,
                 'odt'   => 'OpenDocument',
                 'docx'  => 'Word docx',
                 'epub'  => 'EPUB V2',
                 'epub3' => 'EPUB V3'

    assert_equal PandocRuby::WRITERS,
                 PandocRuby::STRING_WRITERS.merge(PandocRuby::BINARY_WRITERS)
  end
end
