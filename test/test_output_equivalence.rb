require 'helper'
require 'docx'
require 'tempfile'

class TestOutputEquivalence < Test::Unit::TestCase

  def setup
    @file = File.join(File.dirname(__FILE__), 'files', 'code-test.md')
    PandocRuby.allow_file_paths = true
    @pandoc_ruby_docx_path = Dir::Tmpname.make_tmpname(
      "/tmp/pandoc-ruby-code-test", ".docx"
    )
    @pandoc_docx_path = Dir::Tmpname.make_tmpname(
      "/tmp/pandoc-code-test", ".docx"
    )
  end

  def teardown
    PandocRuby.pandoc_path = 'pandoc'
    PandocRuby.allow_file_paths = false
    if File.exist?(@pandoc_ruby_docx_path)
      File.delete(@pandoc_ruby_docx_path)
    end
    if File.exist?(@pandoc_docx_path)
      File.delete(@pandoc_docx_path)
    end
  end

  should "output html with code escaping matching pandoc called via shell" do
    pandoc_ruby_html = PandocRuby.new(@file).to_html
    pandoc_html = %x[cat #{@file} | pandoc --to html]
    assert_equal pandoc_html, pandoc_ruby_html
  end

  should "output html with code escaping matching expected pandoc output" do
    pandoc_ruby_html = PandocRuby.new(@file).to_html
    pandoc_html = "\
<p>Inline Code: <code>&lt;inline-code&gt;</code></p>
<pre><code>Block code! &lt;block-code&gt;</code></pre>
"
    assert_equal pandoc_html, pandoc_ruby_html
  end

  should "have same contents when converting to docx" do
    PandocRuby.convert(@file, o: @pandoc_ruby_docx_path)
    %x[cat #{@file} | pandoc -o #{@pandoc_docx_path}]
    pandoc_ruby_docx_paragraphs = []
    Docx::Document.open(@pandoc_ruby_docx_path) \
      .paragraphs \
      .each do |p|
        pandoc_ruby_docx_paragraphs << p.to_s
    end
    pandoc_docx_paragraphs = []
    Docx::Document.open(@pandoc_docx_path) \
      .paragraphs \
      .each do |p|
        pandoc_docx_paragraphs << p.to_s
    end
    assert_equal pandoc_docx_paragraphs, pandoc_ruby_docx_paragraphs
  end
end

