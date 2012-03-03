require 'test_helper'

class TestConversions < Test::Unit::TestCase
  
  def self.formatted_strings
    h = Hash.new
    h[:native] =
      "[Header 1 [Str "This",Space,Str "is",Space,Str "a",Space,Str "Title"]\n,Para [Str "Some",Space,Emph [Str "emphasized",Space,Str "text"],Space,Str "and",Space,Link [Str "a",Space,Str "link"] ("http://daringfireball.net/projects/markdown/","")]]\n"
    h[:json] =
      "[{"docTitle":[],"docAuthors":[],"docDate":[]},[{"Header":[1,[{"Str":"This"},"Space",{"Str":"is"},"Space",{"Str":"a"},"Space",{"Str":"Title"}]]},{"Para":[{"Str":"Some"},"Space",{"Emph":[{"Str":"emphasized"},"Space",{"Str":"text"}]},"Space",{"Str":"and"},"Space",{"Link":[[{"Str":"a"},"Space",{"Str":"link"}],["http://daringfireball.net/projects/markdown/",""]]}]}]]\n"
    h[:html] =
      "<h1 id="this-is-a-title">This is a Title</h1>\n<p>Some <em>emphasized text</em> and <a href="http://daringfireball.net/projects/markdown/">a link</a></p>\n"
    h[:html5] =
      "<h1 id="this-is-a-title">This is a Title</h1>\n<p>Some <em>emphasized text</em> and <a href="http://daringfireball.net/projects/markdown/">a link</a></p>\n"
    h[:s5] =
      "<div class="section slide level1" id="this-is-a-title">\n<h1>This is a Title</h1>\n<p>Some <em>emphasized text</em> and <a href="http://daringfireball.net/projects/markdown/">a link</a></p>\n</div>\n"
    h[:slidy] =
      "<div class="section slide level1" id="this-is-a-title">\n<h1 id="this-is-a-title">This is a Title</h1>\n<p>Some <em>emphasized text</em> and <a href="http://daringfireball.net/projects/markdown/">a link</a></p>\n</div>\n"
    h[:dzslides] =
      "<section class="slide level1" id="this-is-a-title">\n<h1 id="this-is-a-title">This is a Title</h1>\n<p>Some <em>emphasized text</em> and <a href="http://daringfireball.net/projects/markdown/">a link</a></p>\n</section>\n"
    h[:docbook] =
      "<sect1 id="this-is-a-title">\n  <title>This is a Title</title>\n  <para>\n    Some <emphasis>emphasized text</emphasis> and\n    <ulink url="http://daringfireball.net/projects/markdown/">a\n    link</ulink>\n  </para>\n</sect1>\n"
    h[:opendocument] =
      "<text:h text:style-name="Heading_20_1" text:outline-level="1">This is a\nTitle</text:h>\n<text:p text:style-name="First_20_paragraph">Some\n<text:span text:style-name="T1">emphasized</text:span><text:span text:style-name="T2">\n</text:span><text:span text:style-name="T3">text</text:span> and\n<text:a xlink:type="simple" xlink:href="http://daringfireball.net/projects/markdown/" office:name=""><text:span text:style-name="Definition">a\nlink</text:span></text:a></text:p>\n"
    h[:latex] =
      "\section{This is a Title}\n\nSome \emph{emphasized text} and\n\href{http://daringfireball.net/projects/markdown/}{a link}\n"
    h[:beamer] =
      "\begin{frame}\frametitle{This is a Title}\n\nSome \emph{emphasized text} and\n\href{http://daringfireball.net/projects/markdown/}{a link}\n\n\end{frame}\n"
    h[:context] =
      "\section[this-is-a-title]{This is a Title}\n\nSome {\em emphasized text} and\n\useURL[url1][http://daringfireball.net/projects/markdown/][][a\nlink]\from[url1]\n"
    h[:texinfo] =
      "@node Top\n@top Top\n\n@menu\n* This is a Title::\n@end menu\n\n@node This is a Title\n@chapter This is a Title\nSome @emph{emphasized text} and @uref{http://daringfireball.net/projects/markdown/,a link}\n"
    h[:man] =
      ".SH This is a Title\n.PP\nSome \f[I]emphasized text\f[] and a\nlink (http://daringfireball.net/projects/markdown/)\n"
    h[:markdown] =
      "This is a Title\n===============\n\nSome *emphasized text* and [a\nlink](http://daringfireball.net/projects/markdown/)\n"
    h[:plain] =
      "This is a Title\n===============\n\nSome emphasized text and a link\n"
    h[:rst] =
      "This is a Title\n===============\n\nSome *emphasized text* and `a\nlink <http://daringfireball.net/projects/markdown/>`_\n"
    h[:mediawiki] =
      "= This is a Title =\n\nSome ''emphasized text'' and [http://daringfireball.net/projects/markdown/ a link]\n\n"
    h[:textile] =
      "h1. This is a Title\n\nSome _emphasized text_ and "a link":http://daringfireball.net/projects/markdown/\n\n"
    h[:rtf] =
      "{\pard \ql \f0 \sa180 \li0 \fi0 \b \fs36 This is a Title\par}\n{\pard \ql \f0 \sa180 \li0 \fi0 Some {\i emphasized text} and {\field{\*\fldinst{HYPERLINK "http://daringfireball.net/projects/markdown/"}}{\fldrslt{\ul\na link\n}}}\n\par}\n\n"
    h[:org] =
      "* This is a Title\n\nSome /emphasized text/ and\n[[http://daringfireball.net/projects/markdown/][a link]]\n"
    h[:asciidoc] =
      "This is a Title\n---------------\n\nSome _emphasized text_ and\nhttp://daringfireball.net/projects/markdown/[a link]\n"
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
