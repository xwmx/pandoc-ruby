require 'open3'
require 'tempfile'

class PandocRuby
  @@bin_path = nil
  @@allow_file_paths = false
  
  EXECUTABLES = %W[
    pandoc
    markdown2pdf
    html2markdown
    hsmarkdown
  ]
  
  READERS = {
    'native'   => 'pandoc native',
    'json'     => 'pandoc JSON',
    'markdown' => 'markdown',
    'rst'      => 'reStructuredText',
    'textile'  => 'textile',
    'html'     => 'HTML',
    'latex'    => 'LaTeX',
  }

  STRING_WRITERS = {
    'native'        => 'pandoc native',
    'json'          => 'pandoc JSON',
    'html'          => 'HTML',
    'html5'         => 'HTML5',
    's5'            => 'S5 HTML slideshow',
    'slidy'         => 'Slidy HTML slideshow',
    'dzslides'      => 'Dzslides HTML slideshow',
    'docbook'       => 'DocBook XML',
    'opendocument'  => 'OpenDocument XML',
    'latex'         => 'LaTeX',
    'beamer'        => 'Beamer PDF slideshow',
    'context'       => 'ConTeXt',
    'texinfo'       => 'GNU Texinfo',
    'man'           => 'groff man',
    'markdown'      => 'markdown',
    'plain'         => 'plain',
    'rst'           => 'reStructuredText',
    'mediawiki'     => 'MediaWiki markup',
    'textile'       => 'textile',
    'rtf'           => 'rich text format',
    'org'           => 'emacs org mode',
    'asciidoc'      => 'asciidoc'
  }

  BINARY_WRITERS = {
    'odt'   => 'OpenDocument',
    'docx'  => 'Word docx',
    'epub'  => 'EPUB V2',
    'epub3' => 'EPUB V3'
  }

  WRITERS = STRING_WRITERS.merge(BINARY_WRITERS)
  
  def self.bin_path=(path)
    @@bin_path = path
  end
  
  def self.allow_file_paths=(value)
    @@allow_file_paths = value
  end
  
  def self.convert(*args)
    new(*args).convert
  end

  attr_accessor :options
  def options; @options || [] end
  
  attr_accessor :option_string
  def options_string; @option_string || '' end

  attr_accessor :binary_output
  def binary_output; @binary_output || false end
  
  attr_accessor :writer
  def writer; @writer || 'html' end

  def initialize(*args)
    target = args.shift
    @target = if @@allow_file_paths && File.exists?(target)
      File.read(target)
    else
      target rescue target
    end
    @executable = args.shift if EXECUTABLES.include?(args[0])
    self.options = args
  end

  def executable
    @executable ||= 'pandoc'
    @@bin_path ? File.join(@@bin_path, @executable) : @executable
  end

  def command_with_options
    self.executable + self.option_string
  end

  def convert_binary
    begin
      tmp_file = Tempfile.new('pandoc-conversion')
      self.options += [{:output => tmp_file.path}]
      self.option_string =  "#{self.option_string} --output #{tmp_file.path}"
      execute(self.command_with_options)
      return IO.binread(tmp_file)
    ensure
      tmp_file.close
      tmp_file.unlink
    end
  end

  def convert_string
    execute(self.command_with_options)
  end

  def convert(*args)
    self.options += args if args
    self.option_string = stringify_options(self.options)
    if self.binary_output
      self.convert_binary
    else
      self.convert_string
    end
  end
  alias_method :to_s, :convert
  
  class << self
    READERS.each_key do |r|
      define_method(r) do |*args|
        args += [{:from => r}]
        new(*args)
      end
    end
  end
  
  WRITERS.each_key do |w|
    define_method(:"to_#{w}") do |*args|
      args += [{:to => w.to_sym}]
      convert(*args)
    end
  end
  
private

  def execute(command)
    output = ''
    Open3::popen3(command) do |stdin, stdout, stderr| 
      stdin.puts @target 
      stdin.close
      output = stdout.read 
    end
    output
  end

  def stringify_options(opts = [])
    opts.inject('') do |string, (option, value)|
      string += case
                when value != nil
                  create_option(option, value)
                when option.respond_to?(:each_pair)
                  stringify_options(option)
                else
                  create_option(option)
                end
    end
  end

  def create_option(flag, argument = nil)
    return if !flag
    set_pandoc_ruby_options(flag, argument)
    if !!argument
      "#{option_flag(flag)} #{argument}"
    else
      option_flag(flag)
    end
  end

  def option_flag(flag)
    if flag.length == 1
      " -#{flag}"
    else
      " --#{flag.to_s.gsub(/_/, '-')}"
    end
  end

  def set_pandoc_ruby_options(flag, argument = nil)
    case flag.to_sym
    when :t, :to
      self.writer = argument.to_s
      self.binary_output = true if BINARY_WRITERS.keys.include?(self.writer)
    end
  end

end
