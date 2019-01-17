#!/usr/bin/env ruby

# From on Ryan Tomayako's benchmark script from:
#   http://tomayko.com/writings/ruby-markdown-libraries-real-cheap-for-you-two-for-price-of-one

iterations = 100
test_file = File.join(File.dirname(__FILE__), 'files', 'benchmark.txt')
impl_gems = {
  'BlueCloth'  => 'bluecloth',
  'RDiscount'  => 'rdiscount',
  'Maruku'     => 'maruku',
  'PandocRuby' => 'pandoc-ruby'
}

implementations = impl_gems.keys

# Attempt to require each implementation and remove any that are not
# installed.
implementations.reject! do |class_name|
  begin
    require impl_gems[class_name]
    false
  rescue LoadError => boom
    puts "#{class_name} excluded. Try: gem install #{impl_gems[class_name]}"
    true
  end
end

# Grab actual class objects.
implementations.map! { |class_name| Object.const_get(class_name) }

def benchmark(implementation, text, iterations)
  start = Time.now
  iterations.times do |_i|
    implementation.new(text).to_html
  end
  Time.now - start
end

test_data = File.read(test_file)

puts 'Spinning up ...'
implementations.each { |impl| benchmark(impl, test_data, 1) }

puts 'Running benchmarks ...'
results =
  implementations.inject([]) do |r, impl|
    GC.start
    r << [impl, benchmark(impl, test_data, iterations)]
  end

puts "Results for #{iterations} iterations:"
results.each do |impl, time|
  printf "  %10s %09.06fs total time, %09.06fs average\n",
         "#{impl}:",
         time,
         time / iterations
end
