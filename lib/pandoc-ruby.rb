require 'open4'

class PandocRuby
  @@bin = 'pandoc'

  def self.bin=(path)
    @@bin = path
  end

  def self.convert(*args)
    new(*args).convert
  end

  def initialize(target, options = {})
    @target  = File.exists?(target) ? File.read(target) : target rescue target
    @options = options
  end

  def execute(command)
    pid, stdin, stdout, stderr = Open4.popen4(command)
    stdin.puts @target
    stdin.close
    stdout.read.strip
  end

  def convert
    execute @@bin + convert_options
  end
  alias_method :to_s, :convert

  def convert_options(options = {})
    @options.inject('') do |string, (flag, value)|
      if flag.to_s.length == 1
        string + " -#{flag} #{value}"
      else
        string + " --#{flag}=#{value}"
      end
    end
  end
end