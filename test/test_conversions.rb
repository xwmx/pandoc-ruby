require 'test_helper'

class TestConversions < Test::Unit::TestCase
  
  def self.formatted_strings
    h = Hash.new
    h[:markdown] =
      "# This is a Title\n\nSome *emphasized text* and\n[a link](http://daringfireball.net/projects/markdown/)"
    h[:html] =
      "<div id=\"this-is-a-title\"\n><h1\n  >This is a Title</h1\n  ><p\n  >Some <em\n    >emphasized text</em\n    > and <a href=\"http://daringfireball.net/projects/markdown/\"\n    >a link</a\n    ></p\n  ></div\n>"
    h[:rst] =
      "This is a Title\n===============\n\nSome *emphasized text* and\n`a link <http://daringfireball.net/projects/markdown/>`_"
    h[:latex] =
      "\\section{This is a Title}\n\nSome \\emph{emphasized text} and\n\\href{http://daringfireball.net/projects/markdown/}{a link}"
    h[:rtf] =
      "{\\pard \\ql \\f0 \\sa180 \\li0 \\fi0 \\b \\fs36 This is a Title\\par}\n{\\pard \\ql \\f0 \\sa180 \\li0 \\fi0 Some {\\i emphasized text} and {\\field{\\*\\fldinst{HYPERLINK \"http://daringfireball.net/projects/markdown/\"}}{\\fldrslt{\\ul\na link\n}}}\n\\par}"
    h[:context] =
      "\\subject{This is a Title}\n\nSome {\\em emphasized text} and\n\\useURL[1][http://daringfireball.net/projects/markdown/][][a link]\\from[1]"
    h[:man] =
      ".SH This is a Title\n.PP\nSome \\f[I]emphasized text\\f[] and\na link (http://daringfireball.net/projects/markdown/)"
    h[:mediawiki] =
      "== This is a Title ==\n\nSome ''emphasized text'' and [http://daringfireball.net/projects/markdown/ a link]"
    h[:texinfo] =
      "@node Top\n@top Top\n\n@menu\n* This is a Title::\n@end menu\n\n@node This is a Title\n@chapter This is a Title\nSome @emph{emphasized text} and @uref{http://daringfireball.net/projects/markdown/,a link}"
    h[:docbook] =
      "<section>\n  <title>This is a Title</title>\n  <para>\n    Some <emphasis>emphasized text</emphasis> and\n    <ulink url=\"http://daringfireball.net/projects/markdown/\">a link</ulink>\n  </para>\n</section>"
    h[:opendocument] =
      "<office:document-content xmlns:office=\"urn:oasis:names:tc:opendocument:xmlns:office:1.0\" xmlns:style=\"urn:oasis:names:tc:opendocument:xmlns:style:1.0\" xmlns:text=\"urn:oasis:names:tc:opendocument:xmlns:text:1.0\" xmlns:table=\"urn:oasis:names:tc:opendocument:xmlns:table:1.0\" xmlns:draw=\"urn:oasis:names:tc:opendocument:xmlns:drawing:1.0\" xmlns:fo=\"urn:oasis:names:tc:opendocument:xmlns:xsl-fo-compatible:1.0\" xmlns:xlink=\"http://www.w3.org/1999/xlink\" xmlns:dc=\"http://purl.org/dc/elements/1.1/\" xmlns:meta=\"urn:oasis:names:tc:opendocument:xmlns:meta:1.0\" xmlns:number=\"urn:oasis:names:tc:opendocument:xmlns:datastyle:1.0\" xmlns:svg=\"urn:oasis:names:tc:opendocument:xmlns:svg-compatible:1.0\" xmlns:chart=\"urn:oasis:names:tc:opendocument:xmlns:chart:1.0\" xmlns:dr3d=\"urn:oasis:names:tc:opendocument:xmlns:dr3d:1.0\" xmlns:math=\"http://www.w3.org/1998/Math/MathML\" xmlns:form=\"urn:oasis:names:tc:opendocument:xmlns:form:1.0\" xmlns:script=\"urn:oasis:names:tc:opendocument:xmlns:script:1.0\" xmlns:ooo=\"http://openoffice.org/2004/office\" xmlns:ooow=\"http://openoffice.org/2004/writer\" xmlns:oooc=\"http://openoffice.org/2004/calc\" xmlns:dom=\"http://www.w3.org/2001/xml-events\" xmlns:xforms=\"http://www.w3.org/2002/xforms\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" office:version=\"1.0\">\n  <office:scripts />\n  <office:font-face-decls>\n    <style:font-face style:name=\"&amp;apos;Lucida Sans Unicode&amp;apos;\" svg:font-family=\"Lucida Sans Unicode\" />\n    <style:font-face style:name=\"&amp;apos;Tahoma&amp;apos;\" svg:font-family=\"Tahoma\" />\n    <style:font-face style:name=\"&amp;apos;Times New Roman&amp;apos;\" svg:font-family=\"Times New Roman\" />\n  </office:font-face-decls>\n  <office:automatic-styles>\n    <style:style style:name=\"T1\" style:family=\"text\"><style:text-properties fo:font-style=\"italic\" style:font-style-asian=\"italic\" style:font-style-complex=\"italic\" /></style:style>\n    <style:style style:name=\"T2\" style:family=\"text\"><style:text-properties fo:font-style=\"italic\" style:font-style-asian=\"italic\" style:font-style-complex=\"italic\" /></style:style>\n    <style:style style:name=\"T3\" style:family=\"text\"><style:text-properties fo:font-style=\"italic\" style:font-style-asian=\"italic\" style:font-style-complex=\"italic\" /></style:style>\n  </office:automatic-styles>\n  <text:h text:style-name=\"Heading_20_1\" text:outline-level=\"1\">This\n                                                                is a Title</text:h>\n  <text:p text:style-name=\"Text_20_body\">Some\n                                         <text:span text:style-name=\"T1\">emphasized</text:span><text:span text:style-name=\"T2\"> </text:span><text:span text:style-name=\"T3\">text</text:span>\n                                         and\n                                         <text:a xlink:type=\"simple\" xlink:href=\"http://daringfireball.net/projects/markdown/\" office:name=\"\"><text:span text:style-name=\"Definition\">a link</text:span></text:a></text:p>\n  \n</office:document-content>"
    h[:s5] =
      "<div class=\"layout\">\n<div id=\"controls\"></div>\n<div id=\"currentSlide\"></div>\n<div id=\"header\"></div>\n<div id=\"footer\">\n<h1\n></h1\n><h2\n></h2\n></div>\n</div>\n<div class=\"presentation\">\n\n<div class=\"slide\">\n<h1\n>This is a Title</h1\n><p\n>Some <em\n  >emphasized text</em\n  > and <a href=\"http://daringfireball.net/projects/markdown/\"\n  >a link</a\n  ></p\n></div>\n</div>"
    return h
  end
  
  [:markdown, :html, :rst, :latex].each do |from|
    formatted_strings.each_key do |format|
      unless from == format
        should "convert #{from} to #{format}" do
          assert_equal(
            PandocRuby.convert(TestConversions.formatted_strings[from], :from => from, :to => format), 
            TestConversions.formatted_strings[format]
          )
        end
      end
    end
  end
  
end
