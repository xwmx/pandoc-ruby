require 'open4'

class PandocRuby
  @@bin_path = nil
  EXECUTABLES = %W[
    pandoc
    markdown2pdf
    html2markdown
    hsmarkdown
  ]
  
  def self.bin_path=(path)
    @@bin_path = bin_path
  end

  def self.convert(*args)
    new(*args).convert
  end

  def initialize(target, *args)
    @target  = File.exists?(target) ? File.read(target) : target rescue target
    if args[0] && !args[0].respond_to?(:merge) && EXECUTABLES.include?(args[0])
      @executable = args[0]
    else
      @executable = 'pandoc'
    end
    @options = args.last.respond_to?(:merge) ? args.last : {}
  end

  def execute(command)
    pid, stdin, stdout, stderr = Open4.popen4(command)
    stdin.puts @target
    stdin.close
    stdout.read.strip
  end

  def convert
    if @@bin_path
      execute File.join(@@bin_path, @executable) + convert_options
    else
      execute @executable + convert_options
    end
  end
  alias_method :to_s, :convert

  def convert_options
    @options.inject('') do |string, (flag, value)|
      if flag.to_s.length == 1
        string + " -#{flag} #{value}"
      else
        string + " --#{flag}=#{value}"
      end
    end
  end
end