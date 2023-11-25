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

        assert_equal(
          to_content.strip,
          converted_content.strip,
          <<-HEREDOC
---------
EXPECTED:
---------
#{to_content.strip}
---------
-------
ACTUAL:
-------
#{converted_content.strip}
-------
          HEREDOC
        )
      end
    end
  end

  describe '.docx' do
    it "converts from docx to html" do
      converted_content = PandocRuby.convert(
        ['./test/files/reference.docx'],
        :from => 'docx',
        :to   => 'html'
      )
      assert_equal("<p>Hello World.</p>", converted_content.strip)
    end

    it "raises an error when attempting to convert doc with docx format" do
      error = assert_raises(RuntimeError) do
        PandocRuby.convert(
          ['./test/files/reference.doc'],
          :from => 'docx',
          :to   => 'html'
        )
      end

      assert_match(/couldn't unpack docx container/, error.message)
    end

    it "raises an error when attempting to convert doc with doc format" do
      error = assert_raises(RuntimeError) do
        PandocRuby.convert(
          ['./test/files/reference.doc'],
          :from => 'doc',
          :to   => 'html'
        )
      end

      assert_match(/Pandoc can convert from DOCX, but not from DOC./, error.message)
    end
  end
end
