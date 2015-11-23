$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'benchmark/ips'
require 'ishin'

# Non-mixin version to be used with .to_hash
class Simple
  attr_reader :test

  def initialize
    @test = rand
  end
end

Benchmark.ips do |x|
  x.config(time: 5, warmup: 2)

  x.report('symbolize: true') do
    Ishin.to_hash(Simple.new, symbolize: true)
  end

  x.report('symbolize: false') do
    Ishin.to_hash(Simple.new, symbolize: false)
  end

  x.compare!
end
