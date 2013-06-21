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

  WRITERS = {
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

  def initialize(*args)
    target = args.shift
    @target = if @@allow_file_paths && File.exists?(target)
      File.read(target)
    else
      target rescue target
    end
    @executable = EXECUTABLES.include?(args[0]) ? args.shift : 'pandoc'
    self.options = args
  end

  def convert_binary(executable)
    tmp_file = Tempfile.new('pandoc-conversion')
    begin
      self.options += [{:output => tmp_file.path}]
      execute executable + stringify_options(self.options)
      return IO.binread(tmp_file)
    ensure
      tmp_file.unlink
    end
  end

  def convert(*args)
    self.options += args if args
    executable = @@bin_path ? File.join(@@bin_path, @executable) : @executable
    if will_output_binary?(args)
      convert_binary(executable)
    else
      execute executable + stringify_options(self.options)
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
  
  WRITERS.merge(BINARY_WRITERS).each_key do |w|
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
    if !!argument
      "#{option_flag(flag)} #{argument}"
    else
      option_flag(flag)
    end
  end

  def option_flag(flag)
    return if !flag
    if flag.length == 1
      " -#{flag}"
    else
      " --#{flag.to_s.gsub(/_/, '-')}"
    end
  end

  def will_output_binary?(opts = [])
    (@options+opts).flatten.each do |opt|
      if opt.respond_to?(:each_pair)
        opt.each_pair do |opt_key, opt_value|
          if opt_key == :to && BINARY_WRITERS.keys.include?(opt_value.to_s)
            return true
          end 
        end
      end
    end
    false
  end

end
