require 'open3'
require 'tempfile'
require 'timeout'

class PandocRuby
  # Use the pandoc command with a custom executable path.
  @pandoc_path = 'pandoc'
  class << self
    attr_accessor :pandoc_path
  end

  # The available readers and their corresponding names. The keys are used to
  # generate methods and specify options to Pandoc.
  READERS = {
    'biblatex'          => 'BibLaTeX bibliography',
    'bibtex'            => 'BibTeX bibliography',
    'commonmark'        => 'CommonMark Markdown',
    'commonmark_x'      => 'CommonMark Markdown with extensions',
    'creole'            => 'Creole 1.0',
    'csljson'           => 'CSL JSON bibliography',
    'csv'               => 'CSV table',
    'docbook'           => 'DocBook',
    'docx'              => 'Word docx',
    'dokuwiki'          => 'DokuWiki markup',
    'endnotexml'        => 'EndNote XML bibliography',
    'epub'              => 'EPUB',
    'fb2'               => 'FictionBook2 e-book',
    'gfm'               => 'GitHub-Flavored Markdown',
    'haddock'           => 'Haddock markup',
    'html'              => 'HTML',
    'ipynb'             => 'Jupyter notebook',
    'jats'              => 'JATS XML',
    'jira'              => 'Jira wiki markup',
    'json'              => 'JSON version of native AST',
    'latex'             => 'LaTex',
    'man'               => 'roff man',
    'markdown'          => "Pandoc's Markdown",
    'markdown_mmd'      => 'MultiMarkdown',
    'markdown_phpextra' => 'PHP Markdown Extra',
    'markdown_strict'   => 'original unextended Markdown',
    'mediawiki'         => 'MediaWiki markup',
    'muse'              => 'Muse',
    'native'            => 'native Haskell',
    'odt'               => 'ODT',
    'opml'              => 'OPML',
    'org'               => 'Emacs Org mode',
    'ris'               => 'RIS bibliography',
    'rst'               => 'reStructuredText',
    'rtf'               => 'Rich Text Format',
    't2t'               => 'txt2tags',
    'textile'           => 'Textile',
    'tikiwiki'          => 'TikiWiki markup',
    'tsv'               => 'TSV table',
    'twiki'             => 'TWiki markup',
    'vimwiki'           => 'Vimwiki'
  }.freeze

  # The available string writers and their corresponding names. The keys are
  # used to generate methods and specify options to Pandoc.
  STRING_WRITERS = {
    'asciidoc'              => 'AsciiDoc',
    'asciidoctor'           => 'AsciiDoctor',
    'beamer'                => 'LaTeX beamer slide show',
    'biblatex'              => 'BibLaTeX bibliography',
    'bibtex'                => 'BibTeX bibliography',
    'chunkedhtml'           => 'zip archive of multiple linked HTML files',
    'commonmark'            => 'CommonMark Markdown',
    'commonmark_x'          => 'CommonMark Markdown with extensions',
    'context'               => 'ConTeXt',
    'csljson'               => 'CSL JSON bibliography',
    'docbook'               => 'DocBook 4',
    'docbook4'              => 'DocBook 4',
    'docbook5'              => 'DocBook 5',
    'dokuwiki'              => 'DokuWiki markup',
    'fb2'                   => 'FictionBook2 e-book',
    'gfm'                   => 'GitHub-Flavored Markdown',
    'haddock'               => 'Haddock markup',
    'html'                  => 'HTML, i.e.  HTML5/XHTML polyglot markup',
    'html5'                 => 'HTML, i.e.  HTML5/XHTML polyglot markup',
    'html4'                 => 'XHTML 1.0 Transitional',
    'icml'                  => 'InDesign ICML',
    'ipynb'                 => 'Jupyter notebook',
    'jats_archiving'        => 'JATS XML, Archiving and Interchange Tag Set',
    'jats_articleauthoring' => 'JATS XML, Article Authoring Tag Set',
    'jats_publishing'       => 'JATS XML, Journal Publishing Tag Set',
    'jats'                  => 'alias for jats_archiving',
    'jira'                  => 'Jira wiki markup',
    'json'                  => 'JSON version of native AST',
    'latex'                 => 'LaTex',
    'man'                   => 'roff man',
    'markdown'              => "Pandoc's Markdown",
    'markdown_mmd'          => 'MultiMarkdown',
    'markdown_phpextra'     => 'PHP Markdown Extra',
    'markdown_strict'       => 'original unextended Markdown',
    'markua'                => 'Markua',
    'mediawiki'             => 'MediaWiki markup',
    'ms'                    => 'roff ms',
    'muse'                  => 'Muse',
    'native'                => 'native Haskell',
    'opml'                  => 'OPML',
    'opendocument'          => 'OpenDocument',
    'org'                   => 'Emacs Org mode',
    'pdf'                   => 'PDF',
    'plain'                 => 'plain text',
    'pptx'                  => 'PowerPoint slide show',
    'rst'                   => 'reStructuredText',
    'rtf'                   => 'Rich Text Format',
    'texinfo'               => 'GNU Texinfo',
    'textile'               => 'Textile',
    'slideous'              => 'Slideous HTML and JavaScript slide show',
    'slidy'                 => 'Slidy HTML and JavaScript slide show',
    'dzslides'              => 'DZSlides HTML5 + JavaScript slide show',
    'revealjs'              => 'reveal.js HTML5 + JavaScript slide show',
    's5'                    => 'S5 HTML and JavaScript slide show',
    'tei'                   => 'TEI Simple',
    'xwiki'                 => 'XWiki markup',
    'zimwiki'               => 'ZimWiki markup'
  }.freeze

  # The available binary writers and their corresponding names. The keys are
  # used to generate methods and specify options to Pandoc.
  BINARY_WRITERS = {
    'odt'   => 'OpenOffice text document',
    'docx'  => 'Word docx',
    'epub'  => 'EPUB v3',
    'epub2' => 'EPUB v2',
    'epub3' => 'EPUB v3'
  }.freeze

  # All of the available Writers.
  WRITERS = STRING_WRITERS.merge(BINARY_WRITERS)

  # A shortcut method that creates a new PandocRuby object and immediately
  # calls `#convert`. Options passed to this method are passed directly to
  # `#new` and treated the same as if they were passed directly to the
  # initializer.
  def self.convert(*args)
    new(*args).convert
  end

  attr_writer :binary_output

  def binary_output
    @binary_output  ||= false
  end

  attr_writer :options

  def options
    @options        ||= []
  end

  attr_writer :option_string

  def option_string
    @option_string  ||= ''
  end

  attr_writer :writer

  def writer
    @writer         ||= 'html'
  end

  attr_accessor :input_files
  attr_accessor :input_string

  # Create a new PandocRuby converter object. The first argument contains the
  # input either as string or as an array of filenames.
  #
  # Any other arguments will be converted to pandoc options.
  #
  # Usage:
  #   new("# A String", :option1 => :value, :option2)
  #   new(["/path/to/file.md"], :option1 => :value, :option2)
  #   new(["/to/file1.html", "/to/file2.html"], :option1 => :value)
  def initialize(*args)
    case args[0]
    when String
      self.input_string = args.shift
    when Array
      self.input_files  = args.shift.map { |f| "'#{f}'" }.join(' ')
    end

    self.options = args
  end

  # Run the conversion. The convert method can take any number of arguments,
  # which will be converted to pandoc options. If options were already
  # specified in an initializer or reader method, they will be combined with
  # any that are passed to this method.
  #
  # Returns a string with the converted content.
  #
  # Example:
  #
  #   PandocRuby.new("# text").convert
  #   # => "<h1 id=\"text\">text</h1>\n"
  def convert(*args)
    self.options        +=  args if args
    self.option_string  =   prepare_options(self.options)

    if self.binary_output
      convert_binary
    else
      convert_string
    end
  end
  alias to_s convert

  # Generate class methods for each of the readers in PandocRuby::READERS.
  # When one of these methods is called, it simply calls the initializer
  # with the `from` option set to the reader key, and returns the object.
  #
  # Example:
  #
  #   PandocRuby.markdown("# text")
  #   # => #<PandocRuby:0x007 @input_string="# text", @options=[{:from=>"markdown"}]
  class << self
    READERS.each_key do |r|
      define_method(r) do |*args|
        args += [{ :from => r }]

        new(*args)
      end
    end
  end

  # Generate instance methods for each of the writers in PandocRuby::WRITERS.
  # When one of these methods is called, it simply calls the `#convert` method
  # with the `to` option set to the writer key, thereby returning the
  # converted string.
  #
  # Example:
  #
  #   PandocRuby.new("# text").to_html
  #   # => "<h1 id=\"text\">text</h1>\n"
  WRITERS.each_key do |w|
    define_method(:"to_#{w}") do |*args|
      args += [{ :to => w.to_sym }]

      convert(*args)
    end
  end

  private

    # Execute the pandoc command for binary writers. A temp file is created
    # and written to, then read back into the program as a string, then the
    # temp file is closed and unlinked.
    def convert_binary
      tmp_file = Tempfile.new('pandoc-conversion')

      begin
        self.options        +=  [{ :output => tmp_file.path }]
        self.option_string  =   "#{self.option_string} --output \"#{tmp_file.path}\""

        execute_pandoc

        return IO.binread(tmp_file)
      ensure
        tmp_file.close

        tmp_file.unlink
      end
    end

    # Execute the pandoc command for string writers.
    def convert_string
      execute_pandoc
    end

    # Wrapper to run pandoc in a consistent, DRY way
    def execute_pandoc
      if !self.input_files.nil?
        execute("#{PandocRuby.pandoc_path} #{self.input_files}#{self.option_string}")
      else
        execute("#{PandocRuby.pandoc_path}#{self.option_string}")
      end
    end

    # Run the command and returns the output.
    def execute(command)
      output = error = exit_status = nil

      @timeout ||= 31_557_600

      Open3.popen3(command) do |stdin, stdout, stderr, wait_thr|
        begin
          Timeout.timeout(@timeout) do
            stdin.puts self.input_string

            stdin.close

            output      = stdout.read
            error       = stderr.read
            exit_status = wait_thr.value
          end
        rescue Timeout::Error => ex
          Process.kill 9, wait_thr.pid

          maybe_ex  = "\n#{ex}" if ex
          error     = "Pandoc timed out after #{@timeout} seconds.#{maybe_ex}"
        end
      end

      raise error unless exit_status && exit_status.success?

      output
    end

    # Builds the option string to be passed to pandoc by iterating over the
    # opts passed in. Recursively calls itself in order to handle hash options.
    def prepare_options(opts = [])
      opts.inject('') do |string, (option, value)|
        string + if value
                   create_option(option, value)
                 elsif option.respond_to?(:each_pair)
                   prepare_options(option)
                 else
                   create_option(option)
                 end
      end
    end

    # Takes a flag and optional argument, uses it to set any relevant options
    # used by the library, and returns string with the option formatted as a
    # command line options. If the option has an argument, it is also included.
    def create_option(flag, argument = nil)
      return '' unless flag

      flag = flag.to_s
      set_pandoc_ruby_options(flag, argument)
      return '' if flag == 'timeout' # pandoc doesn't accept timeouts yet

      if argument.nil?
        format_flag(flag)
      else
        "#{format_flag(flag)} \"#{argument}\""
      end
    end

    # Formats an option flag in order to be used with the pandoc command line
    # tool.
    def format_flag(flag)
      if flag.length == 1
        " -#{flag}"
      elsif flag =~ /^-|\+/
        " #{flag}"
      else
        " --#{flag.to_s.tr('_', '-')}"
      end
    end

    # Takes an option and optional argument and uses them to set any flags
    # used by PandocRuby.
    def set_pandoc_ruby_options(flag, argument = nil)
      case flag
      when 't', 'to'
        self.writer         = argument.to_s
        self.binary_output  = true if BINARY_WRITERS.key?(self.writer)
      when 'timeout'
        @timeout = argument
      end
    end
end
