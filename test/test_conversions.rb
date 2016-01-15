require 'helper'

# Generate tests for converting to and from various formats. Use two nested
# loops to iterate over each source and destination format, using files with
# names of the following structure: "format.#{format_name}"
describe 'Conversions' do
  @extensions = []
  Dir.glob(File.join(File.dirname(__FILE__), 'files', 'format*')) do |f|
    @extensions << f.match(/format\.(\w+)\Z/)[1]
  end

  [:markdown, :html, :rst, :latex].each do |from|
    @extensions.each do |to|
      next if from == to

      it "converts #{from} to #{to}" do
        files_dir     = File.join(File.dirname(__FILE__), 'files')
        from_content  = File.read(File.join(files_dir, "format.#{from}"))
        to_content    = File.read(File.join(files_dir, "format.#{to}"))

        converted_content = PandocRuby.convert(
          from_content,
          :from => from,
          :to   => to
        )
        assert_equal(converted_content.strip, to_content.strip)
      end
    end
  end
end
