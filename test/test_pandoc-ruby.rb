require 'helper'

class TestPandocRuby < Test::Unit::TestCase

  def setup
    @file = File.join(File.dirname(__FILE__), 'files', 'test.md')
    @converter = PandocRuby.new(@file, :t => :rst)
  end

  def teardown
    PandocRuby.bin_path = nil
    PandocRuby.allow_file_paths = false
  end
  
  should "call bare pandoc when passed no options" do
    converter = PandocRuby.new(@file)
    converter.expects(:execute).with('pandoc').returns(true)
    assert converter.convert
  end

  should "convert with altered bin_path" do
    path = %x[which pandoc].strip
    PandocRuby.bin_path = path
    converter = PandocRuby.new(@file)
    converter.expects(:execute).with("#{path}/pandoc").returns(true)
    assert converter.convert
  end

  should "treat file paths as strings by default" do
    assert_equal "<p>#{@file}</p>\n", PandocRuby.new(@file).to_html
  end

  should "treat file paths as file paths when enabled" do
    PandocRuby.allow_file_paths = true
    assert PandocRuby.new(@file).to_html.match(%r{This is a Title})
  end


  should "accept short options" do
    @converter.expects(:execute).with('pandoc -t rst').returns(true)
    assert @converter.convert
  end

  should "accept long options" do
    converter = PandocRuby.new(@file, :to => :rst)
    converter.expects(:execute).with('pandoc --to rst').returns(true)
    assert converter.convert
  end

  should "accept a variety of options in initializer" do
    converter = PandocRuby.new(@file, :s, {
      :f => :markdown, :to => :rst
    }, 'no-wrap')
    converter \
      .expects(:execute) \
      .with('pandoc -s -f markdown --to rst --no-wrap') \
      .returns(true)
    assert converter.convert
  end

  should "accept a variety of options in convert" do
    converter = PandocRuby.new(@file)
    converter \
      .expects(:execute) \
      .with('pandoc -s -f markdown --to rst --no-wrap') \
      .returns(true)
    assert converter.convert(:s, {:f => :markdown, :to => :rst}, 'no-wrap')
  end

  should "convert underscore symbol ares to hyphenated long options" do
    converter = PandocRuby.new(@file, {
      :email_obfuscation => :javascript
    }, :table_of_contents)
    converter \
      .expects(:execute) \
      .with('pandoc --email-obfuscation javascript --table-of-contents') \
      .returns(true)
    assert converter.convert
  end

  should "accept optional executable" do
    converter = PandocRuby.new(@file, 'html2markdown')
    converter.expects(:execute).with('html2markdown').returns(true)
    assert converter.convert
  end

  should "use non-executable second arg as option" do
    converter = PandocRuby.new(@file, 'toc')
    converter.expects(:execute).with('pandoc --toc').returns(true)
    assert converter.convert
  end

  PandocRuby::READERS.each_key do |r|
    should "convert from #{r} with PandocRuby.#{r}" do
      converter = PandocRuby.send(r, @file)
      converter.expects(:execute).with("pandoc --from #{r}").returns(true)
      assert converter.convert
    end
  end

  PandocRuby::STRING_WRITERS.each_key do |w|
    should "convert to #{w} with to_#{w}" do
      converter = PandocRuby.new(@file)
      converter \
        .expects(:execute) \
        .with("pandoc --no-wrap --to #{w}") \
        .returns(true)
      assert converter.send("to_#{w}", :no_wrap)
    end
  end

  PandocRuby::BINARY_WRITERS.each_key do |w|
    should "convert to #{w} with to_#{w}" do
      converter = PandocRuby.new(@file)
      converter \
        .expects(:execute) \
        .with(regexp_matches(/^pandoc --no-wrap --to #{w} --output /)) \
        .returns(true)
      assert converter.send("to_#{w}", :no_wrap)
    end
  end

  should "work with strings" do
    converter = PandocRuby.new('## this is a title')
    assert_match %r(h2), converter.convert
  end

  should "alias to_s" do
    assert_equal @converter.convert, @converter.to_s
  end

  should "have convert class method" do
    assert_equal @converter.convert, PandocRuby.convert(@file, :t => :rst)
  end

  should "run more than 400 times without error" do
    begin
      400.times do
        PandocRuby.convert(@file)
      end
      assert true
    rescue Errno::EMFILE, Errno::EAGAIN => e
      flunk e
    end
  end

  should "have reader and writer constants" do
    assert_equal PandocRuby::READERS, {
      "html"      =>  "HTML",
      "latex"     =>  "LaTeX",
      "textile"   =>  "textile",
      "native"    =>  "pandoc native",
      "markdown"  =>  "markdown",
      "json"      =>  "pandoc JSON",
      "rst"       =>  "reStructuredText"
    }

    assert_equal PandocRuby::STRING_WRITERS, {
      "mediawiki"     =>  "MediaWiki markup",
      "html"          =>  "HTML",
      "plain"         =>  "plain",
      "latex"         =>  "LaTeX",
      "s5"            =>  "S5 HTML slideshow",
      "textile"       =>  "textile",
      "texinfo"       =>  "GNU Texinfo",
      "docbook"       =>  "DocBook XML",
      "html5"         =>  "HTML5",
      "native"        =>  "pandoc native",
      "org"           =>  "emacs org mode",
      "rtf"           =>  "rich text format",
      "markdown"      =>  "markdown",
      "man"           =>  "groff man",
      "dzslides"      =>  "Dzslides HTML slideshow",
      "beamer"        =>  "Beamer PDF slideshow",
      "json"          =>  "pandoc JSON",
      "opendocument"  =>  "OpenDocument XML",
      "slidy"         =>  "Slidy HTML slideshow",
      "rst"           =>  "reStructuredText",
      "context"       =>  "ConTeXt",
      "asciidoc"      =>  "asciidoc"
    }

    assert_equal PandocRuby::BINARY_WRITERS, {
      "odt"   => "OpenDocument",
      "docx"  => "Word docx",
      "epub"  => "EPUB V2",
      "epub3" => "EPUB V3"
    }

    assert_equal PandocRuby::WRITERS, (
      PandocRuby::STRING_WRITERS.merge(PandocRuby::BINARY_WRITERS)
    )
  end
end
