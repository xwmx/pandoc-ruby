require 'test_helper'
require 'mocha'

class PandocRubyTest < Test::Unit::TestCase
  
  def setup
    @file = File.join(File.dirname(__FILE__), 'test.md')
    @converter = PandocRuby.new(@file, :t => :rst)
  end
  
  def teardown
    PandocRuby.bin_path = nil
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
  
  should "accept short options" do
    @converter.expects(:execute).with('pandoc -t rst').returns(true)
    assert @converter.convert
  end
  
  should "accept long options" do
    converter = PandocRuby.new(@file, :to => :rst)
    converter.expects(:execute).with('pandoc --to=rst').returns(true)
    assert converter.convert
  end
  
  should "accept optional executable" do
    converter = PandocRuby.new(@file, 'html2markdown')
    converter.expects(:execute).with('html2markdown').returns(true)
    assert converter.convert
  end
  
  should "not accept non-pandoc optional executable" do
    converter = PandocRuby.new(@file, 'ls')
    converter.expects(:execute).with('pandoc').returns(true)
    assert converter.convert
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
end
