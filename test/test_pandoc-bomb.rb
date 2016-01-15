require 'helper'

class TestPandocBombRuby < Test::Unit::TestCase
  should 'gracefully time out when bombed' do
    file = File.join(File.dirname(__FILE__), 'files', 'bomb.tex')
    contents = File.read(file)

    assert_raise(RuntimeError) do
      PandocRuby.convert(contents, :from => :latex, :to => :html, :timeout => 1)
    end
  end
end
