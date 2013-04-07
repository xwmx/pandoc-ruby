require 'helper'

class TestConversions < Test::Unit::TestCase
  
  def self.formatted_strings
    h = Hash.new
    h[:native] =
      %Q|[Header 1 [Str \"This\",Space,Str \"is\",Space,Str \"a\",Space,Str \"Title\"]\n,Para [Str \"Some\",Space,Emph [Str \"emphasized\",Space,Str \"text\"],Space,Str \"and\",Space,Link [Str \"a\",Space,Str \"link\"] (\"http://daringfireball.net/projects/markdown/\",\"\")]]|
    h[:json] =
      %Q|[{\"docTitle\":[],\"docAuthors\":[],\"docDate\":[]},[{\"Header\":[1,[{\"Str\":\"This\"},\"Space\",{\"Str\":\"is\"},\"Space\",{\"Str\":\"a\"},\"Space\",{\"Str\":\"Title\"}]]},{\"Para\":[{\"Str\":\"Some\"},\"Space\",{\"Emph\":[{\"Str\":\"emphasized\"},\"Space\",{\"Str\":\"text\"}]},\"Space\",{\"Str\":\"and\"},\"Space\",{\"Link\":[[{\"Str\":\"a\"},\"Space\",{\"Str\":\"link\"}],[\"http://daringfireball.net/projects/markdown/\",\"\"]]}]}]]|
    h[:html] =
      %Q|<h1 id=\"this-is-a-title\">This is a Title</h1>\n<p>Some <em>emphasized text</em> and <a href=\"http://daringfireball.net/projects/markdown/\">a link</a></p>|
    h[:html5] =
      %Q|<h1 id=\"this-is-a-title\">This is a Title</h1>\n<p>Some <em>emphasized text</em> and <a href=\"http://daringfireball.net/projects/markdown/\">a link</a></p>|
    h[:s5] =
      %Q|<div class=\"section slide level1\" id=\"this-is-a-title\">\n<h1>This is a Title</h1>\n<p>Some <em>emphasized text</em> and <a href=\"http://daringfireball.net/projects/markdown/\">a link</a></p>\n</div>|
    h[:slidy] =
      %Q|<div class=\"section slide level1\" id=\"this-is-a-title\">\n<h1 id=\"this-is-a-title\">This is a Title</h1>\n<p>Some <em>emphasized text</em> and <a href=\"http://daringfireball.net/projects/markdown/\">a link</a></p>\n</div>|
    h[:dzslides] =
      %Q|<section class=\"slide level1\" id=\"this-is-a-title\">\n<h1 id=\"this-is-a-title\">This is a Title</h1>\n<p>Some <em>emphasized text</em> and <a href=\"http://daringfireball.net/projects/markdown/\">a link</a></p>\n</section>|
    h[:docbook] =
      %Q|<sect1 id=\"this-is-a-title\">\n  <title>This is a Title</title>\n  <para>\n    Some <emphasis>emphasized text</emphasis> and\n    <ulink url=\"http://daringfireball.net/projects/markdown/\">a\n    link</ulink>\n  </para>\n</sect1>|
    h[:opendocument] =
      %Q|<text:h text:style-name=\"Heading_20_1\" text:outline-level=\"1\">This is a\nTitle</text:h>\n<text:p text:style-name=\"First_20_paragraph\">Some\n<text:span text:style-name=\"T1\">emphasized</text:span><text:span text:style-name=\"T2\">\n</text:span><text:span text:style-name=\"T3\">text</text:span> and\n<text:a xlink:type=\"simple\" xlink:href=\"http://daringfireball.net/projects/markdown/\" office:name=\"\"><text:span text:style-name=\"Definition\">a\nlink</text:span></text:a></text:p>|
    h[:latex] =
      %Q|\\section{This is a Title}\n\nSome \\emph{emphasized text} and\n\\href{http://daringfireball.net/projects/markdown/}{a link}|
    h[:beamer] =
      %Q|\\begin{frame}\\frametitle{This is a Title}\n\nSome \\emph{emphasized text} and\n\\href{http://daringfireball.net/projects/markdown/}{a link}\n\n\\end{frame}|
    h[:context] =
      %Q|\\section[this-is-a-title]{This is a Title}\n\nSome {\\em emphasized text} and\n\\useURL[url1][http://daringfireball.net/projects/markdown/][][a\nlink]\\from[url1]|
    h[:texinfo] =
      %Q|@node Top\n@top Top\n\n@menu\n* This is a Title::\n@end menu\n\n@node This is a Title\n@chapter This is a Title\nSome @emph{emphasized text} and @uref{http://daringfireball.net/projects/markdown/,a link}|
    h[:man] =
      %Q|.SH This is a Title\n.PP\nSome \\f[I]emphasized text\\f[] and a\nlink (http://daringfireball.net/projects/markdown/)|
    h[:markdown] =
      %Q|This is a Title\n===============\n\nSome *emphasized text* and [a\nlink](http://daringfireball.net/projects/markdown/)|
    h[:plain] =
      %Q|This is a Title\n===============\n\nSome emphasized text and a link|
    h[:rst] =
      %Q|This is a Title\n===============\n\nSome *emphasized text* and `a\nlink <http://daringfireball.net/projects/markdown/>`_|
    h[:mediawiki] =
      %Q|= This is a Title =\n\nSome ''emphasized text'' and [http://daringfireball.net/projects/markdown/ a link]|
    h[:textile] =
      %Q|h1. This is a Title\n\nSome _emphasized text_ and \"a link\":http://daringfireball.net/projects/markdown/|
    h[:rtf] =
      %Q|{\\pard \\ql \\f0 \\sa180 \\li0 \\fi0 \\b \\fs36 This is a Title\\par}\n{\\pard \\ql \\f0 \\sa180 \\li0 \\fi0 Some {\\i emphasized text} and {\\field{\\*\\fldinst{HYPERLINK \"http://daringfireball.net/projects/markdown/\"}}{\\fldrslt{\\ul\na link\n}}}\n\\par}|
    h[:org] =
      %Q|* This is a Title\n\nSome /emphasized text/ and\n[[http://daringfireball.net/projects/markdown/][a link]]|
    h[:asciidoc] =
      %Q|This is a Title\n---------------\n\nSome _emphasized text_ and\nhttp://daringfireball.net/projects/markdown/[a link]|
    return h
  end
 
  [:markdown, :html, :rst, :latex].each do |from|
    formatted_strings.each_key do |format|
      unless from == format
        should "convert #{from} to #{format}" do
          assert_equal(
            PandocRuby.convert(TestConversions.formatted_strings[from], :from => from, :to => format).strip, 
            TestConversions.formatted_strings[format]
          )
        end
      end
    end
  end
  
end
