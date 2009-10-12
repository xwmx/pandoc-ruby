require 'test_helper'
require 'mocha'

class PandocRubyTest < Test::Unit::TestCase
  
  def setup
    @file = File.join(File.dirname(__FILE__), '..', 'README')
    @converter = PandocRuby.new(@file, :t => :rst)
  end
  
  should "convert mimic default behavior" do
    converter = PandocRuby.new(@file)
    assert converter.expects(:execute).with('pandoc').returns(true)
    converter.convert
  end
  
  should "accept short options" do
    assert @converter.expects(:execute).with('pandoc -t rst').returns(true)
    @converter.convert
  end
  
  should "accept long options" do
    converter = PandocRuby.new(@file, :to => :rst)
    assert converter.expects(:execute).with('pandoc --to=rst').returns(true)
    converter.convert
  end
  
  should "accept optional executable" do
    converter = PandocRuby.new(@file, 'html2markdown')
    assert converter.expects(:execute).with('html2markdown').returns(true)
    converter.convert
  end
  
  should "not accept non-pandoc optional executable" do
    converter = PandocRuby.new(@file, 'ls')
    assert converter.expects(:execute).with('pandoc').returns(true)
    converter.convert
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
