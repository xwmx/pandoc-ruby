require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  warn e.message
  warn 'Run `bundle install` to install missing gems'
  exit e.status_code
end
require 'rake'

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

task :default => :test

require 'rdoc/task'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ''

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "pandoc-ruby #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

require './lib/pandoc-ruby.rb'
desc <<HEREDOC
  Regenerate test files in existing formats.
HEREDOC
task :regenerate_files do
  extensions = []
  files_dir = File.join(File.dirname(__FILE__), 'test', 'files')

  Dir.glob(File.join(files_dir, 'format*')) do |f|
    extensions << f.match(/format\.(\w+)\Z/)[1]
  end

  from_content = File.read(File.join(files_dir, 'format.markdown'))

  extensions.each do |to|
    next if to == 'markdown'

    to_file = File.join(files_dir, "format.#{to}")

    converted_content = PandocRuby.convert(
      from_content,
      :from => 'markdown',
      :to   => to
    )

    File.open(to_file, 'w') do |file|
      file.write(converted_content)
    end
  end
end
