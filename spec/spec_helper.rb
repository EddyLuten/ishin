require "codeclimate-test-reporter"
CodeClimate::TestReporter.start

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'ishin'

RSpec.configure do |config|
  config.run_all_when_everything_filtered = true
end

SimpleStruct = Struct.new(:test)

class MixedInForRecursion
  include Ishin::Mixin

  attr_reader :value

  def initialize
    @value = SimpleStruct.new('recursive')
  end
end

class MixedInDeepRecursion
  include Ishin::Mixin

  attr_reader :value

  def initialize
    @value =
      SimpleStruct.new(
        SimpleStruct.new(
          SimpleStruct.new('deep')
        )
      )
  end
end

class MixedInClass
  include Ishin::Mixin

  attr_reader :key

  def initialize
    @key = 'value'
  end
end

class WontOverrideMixinClass
  include Ishin::Mixin

  attr_reader :key

  def initialize
    @key = 'value'
  end

  def to_hash
    { existing: true }
  end
end

class ExtendedMixedInClass < MixedInClass
  def to_hash
    super.merge({ merged: true })
  end
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
