require 'open4'

class PandocRuby
  @@bin_path = nil
  EXECUTABLES = %W[
    pandoc
    markdown2pdf
    html2markdown
    hsmarkdown
  ]
  
  READERS  = {
    'rst'       => 'reStructuredText',
    'markdown'  => 'markdown',
    'html'      => 'HTML',
    'latex'     => 'LaTeX'
  }

  WRITERS    = {
    'markdown'      => 'markdown',
    'rst'           => 'reStructuredText',
    'html'          => 'HTML',
    'latex'         => 'LaTeX',
    'context'       => 'ConTeXt',
    'man'           => 'groff man',
    'mediawiki'     => 'MediaWiki markup',
    'texinfo'       => 'GNU Texinfo',
    'docbook'       => 'DocBook XML',
    'opendocument'  => 'OpenDocument XML',
    's5'            => 'S5 HTML and javascript slide show',
    'rtf'           => 'rich text format'
  }
  
  def self.bin_path=(path)
    @@bin_path = path
  end

  def self.convert(*args)
    new(*args).convert
  end

  def initialize(*args)
    target = args.shift
    @target  = File.exists?(target) ? File.read(target) : target rescue target
    @executable = EXECUTABLES.include?(args[0]) ? args.shift : 'pandoc'
    @options = args
  end

  def convert
    executable = @@bin_path ? File.join(@@bin_path, @executable) : @executable
    execute executable + convert_options
  end
  alias_method :to_s, :convert
  
  def to_html
    @options << {:to => :html}
    convert
  end
  
private

  def execute(command)
    output = ''
    Open4::popen4(command) do |pid, stdin, stdout, stderr| 
      stdin.puts @target 
      stdin.close
      output = stdout.read.strip 
    end
    output
  end

  def convert_options
    @options.inject('') do |string, opt|
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
