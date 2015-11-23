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

# Mixed-in version
class MixedIn
  include Ishin::Mixin

  attr_reader :test

  def initialize
    @test = rand
  end
end

Benchmark.ips do |x|
  x.config(time: 5, warmup: 2)

  x.report('.to_hash class method') do
    Ishin.to_hash(Simple.new)
  end

  x.report('.to_hash mixin method') do
    MixedIn.new.to_hash
  end

  x.compare!
end
