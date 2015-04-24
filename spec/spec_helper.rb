$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'ishin'

RSpec.configure do |config|
  config.run_all_when_everything_filtered = true
end

class SimpleClass
  attr_accessor :test

  def initialize value
    @test = value
  end
end

class AnotherClass
  attr_reader :something

  def initialize
    @something = 'parent value'
  end
end

module MyMixin
  attr_accessor :nothing

  def initialize
    super
    @nothing = 'mixin value'
  end
end

class ComplexClass < AnotherClass
  include MyMixin

  attr_accessor :anything

  def initialize
    super
    @anything = 'child value'
  end
end

class HasClassVariable
  @@count = 10

  def initialize
    @only_this = 'value'
  end
end
