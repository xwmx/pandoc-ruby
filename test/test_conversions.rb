require 'helper'

# Generate tests for converting to and from various formats. Use two nested
# loops to iterate over each source and destination format, using files with
# names of the following structure: "format.#{format_name}"
class TestConversions < Test::Unit::TestCase
  @extensions = []
  @file_paths = []
  @file_paths = Dir.glob(
    File.join(File.dirname(__FILE__), 'files', 'format*')
  )
  @file_paths.each do |f|
    @extensions << f.match(/format\.(\w+)\Z/)[1]
  end

  [:markdown, :html, :rst, :latex].each do |from|
    @extensions.each do |to|
      next if from == to
      should "convert #{from} to #{to}" do
        @from_content = File.read(
          File.join(File.dirname(__FILE__), 'files', "format.#{from}")
        )
        @to_content = File.read(
          File.join(File.dirname(__FILE__), 'files', "format.#{to}")
        )
        assert_equal(
          PandocRuby.convert(
            @from_content,
            :from => from,
            :to => to
          ).strip,
          @to_content.strip
        )
      end
    end
  end
end
