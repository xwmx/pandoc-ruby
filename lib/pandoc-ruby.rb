require 'open3'

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
    'asciidoc'      => 'asciidoc',
    'odt'           => 'odt',
    'docx'          => 'docx',
    'epub'          => 'epub'
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

  def initialize(*args)
    target = args.shift
    @target = if @@allow_file_paths && File.exists?(target)
      File.read(target)
    else
      target rescue target
    end
    @executable = EXECUTABLES.include?(args[0]) ? args.shift : 'pandoc'
    @options = args
  end

  def convert(*args)
    executable = @@bin_path ? File.join(@@bin_path, @executable) : @executable
    execute executable + convert_options(args)
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
      output = stdout.read.strip 
    end
    output
  end

  def convert_options(opts = [])
    (@options + opts).flatten.inject('') do |string, opt|
      string + if opt.respond_to?(:each_pair)
        convert_opts_with_args(opt)
      else
        opt.to_s.length == 1 ? " -#{opt}" : " --#{opt.to_s.gsub(/_/, '-')}"
      end
    end
  end
  
  def convert_opts_with_args(opt)
    opt.inject('') do |string, (flag, val)|
      flag = flag.to_s.gsub(/_/, '-')
      string + (flag.length == 1 ? " -#{flag} #{val}" : " --#{flag}=#{val}")
    end
  end
end
