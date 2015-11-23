$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'benchmark/ips'
require 'ishin'

# A dummy class used for simply holding some data
class Test
  attr_reader :value
  def initialize(value)
    @value = value
  end
end

Benchmark.ips do |x|
  x.config(time: 5, warmup: 2)

  test_object = Test.new(Test.new(Test.new(Test.new('value'))))

  one_level_options   = { recursive: true, recursion_depth: 2 }
  two_level_options   = { recursive: true, recursion_depth: 3 }
  three_level_options = { recursive: true, recursion_depth: 4 }

  x.report('no recursion') do
    Ishin.to_hash(test_object)
  end

  x.report('one level of recursion') do
    Ishin.to_hash(test_object, one_level_options)
  end

  x.report('two levels of recursion') do
    Ishin.to_hash(test_object, two_level_options)
  end

  x.report('three levels of recursion') do
    Ishin.to_hash(test_object, three_level_options)
  end

  x.compare!
end
