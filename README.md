[![Code Climate](https://codeclimate.com/github/EddyLuten/ishin/badges/gpa.svg)](https://codeclimate.com/github/EddyLuten/ishin)
[![Test Coverage](https://codeclimate.com/github/EddyLuten/ishin/badges/coverage.svg)](https://codeclimate.com/github/EddyLuten/ishin)
[![Gem Version](https://img.shields.io/gem/v/ishin.svg)](https://rubygems.org/gems/ishin)
[![Build Status](https://travis-ci.org/EddyLuten/ishin.svg?branch=master)](https://travis-ci.org/EddyLuten/ishin)

# Ishin

Ishin converts Ruby objects into their Hash representations. It works with plain
old classes, extended classes, classes with mixins, and hashes (see Usage for
more information).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'ishin'
```

And then execute:

    bundle

Or install it manually by:

    gem install ishin

## Requirements

Ishin does not require any other gems to run. There are a few gems used during
development only, but don't affect runtime performance. For details, see
`ishin.gemspec` in the root directory of the project.

## Example

As a class method callable on any object:

```ruby
require 'ishin'

hash = Ishin.to_hash(my_object)
```

Or included in your object as a mixin:

```ruby
class YourClass
  include Ishin::Mixin
  # etc.
end

instance = YourClass.new
hash = instance.to_hash
```

### Usage

A simple example is worth a thousand words:

```ruby
class Animal
  attr_reader :leg_count

  def initialize leg_count
    @leg_count = leg_count
  end
end

dog = Animal.new(4)

dog_hash = Ishin.to_hash(dog)
# => {:leg_count=>4}
```

### Recursion

Ishin also handles object instances nested within other object instances. By
default, recursive hash conversion is turned off. To enable recursion, set the
`recursive` option to `true`:

```ruby
test_struct = Struct.new(:value)
nested_structs = test_struct.new(test_struct.new('value'))


Ishin.to_hash(nested_structs, recursive: true)
# => {:value=>{:value=>"value"}}
```

### Recursion Depth

For deeply nested object instances, a maximum recursion depth can be provided in
combination with the `recursive` option. The default recursion depth is one
(initial call + 1).

```ruby
nest_me = Struct.new(:value)
deep_nesting = nest_me.new(nest_me.new(nest_me.new(nest_me.new('such depth'))))

Ishin.to_hash(deep_nesting, recursive: true, recursion_depth: 2)
# => {:value=>{:value=>{:value=>#<struct value="such depth">}}}
```

Notice in the above example that the recursion stopped after 3 steps (initial
call + 2).

**Warning:** Increasing the recursion depth will affect the runtime of the
conversion process significantly. To see how drastic increased recursion levels
affect performance, run `ruby benchmarks/recursive_bench.rb`

### Expanding Hashes using Recursion

Using recursion, it is also possible to convert hashes containing object
instances to a hash-only representation as well. Notice that this only works if
the `recursive` option is provided.

```ruby
another_struct = Struct.new(:value)
my_hash = {
  my_struct: another_struct.new("yup, it's a struct")
}

Ishin.to_hash(my_hash, recursive: true)
# => {:my_struct=>{:value=>"yup, it's a struct"}}
```

Keep in mind that the `recursive` option works in conjunction with the
`recursion_depth` option.

### Symbolizing Keys

By default, Ishin stores key names as symbols. This behavior can be disabled by
setting the `symbolize` option to `false`.

```ruby
class Dog
  attr_reader :says

  def initialize(says)
    @says = says
  end
end

lassie = Dog.new('Timmy is stuck in a well!')

Ishin.to_hash(lassie)
# => {:says=>"Timmy is stuck in a well!"}
Ishin.to_hash(lassie, symbolize: false)
# => {"says"=>"Timmy is stuck in a well!"}
```
When setting the `symbolize` option to `false`, the explicit conversion of
strings to symbols is prevented. This, however, does *not* mean that hashes
whose keys are already symbols are converted into string-based keys.

### Evaluating Methods

Normally, Ishin does not evaluate methods, but is possible to do so through the
optional `evaluate` option by passing it an array of method names to evaluate.

```ruby
class Speaker
  def say
    "Say what?"
  end
end

speaker = Speaker.new
# => #<Speaker:0x007fb2bb1812d8>
Ishin.to_hash(speaker, evaluate: [ :say ])
# => {:say=>"Say what?"}
```

It is currently only possible to evaluate methods that do not require arguments.

## As a Mixin

To use Ishin as a mixin in your own objects, simply include `Ishin::Mixin`:

```ruby
class MyObject
  include Ishin::Mixin
  # etc.
end
```

Your object now exposes a method named `to_hash` taking the same options at the
`Ishin::to_hash` class method documented above.

## Running Code Quality Tools

To run the code quality tools Rubocop, Reek, and RSpec, run the following
command:

    rake

## Running the Specs

Once `bundle` is executed, simply run:

    rake spec

## Running the Benchmarks

To give an idea on what kind of performance can be expected from Ishin, there
are a few IPS (iterations per second) benchmarks located in the `benchmarks`
directory. These can all be executed in series by running:

    rake bench

## Changelog

* 0.1.0
  * Initial release.
* 0.2.0
  * Added `Ishin::Mixin`.
* 0.2.1
  * Now using `Struct.to_h` when converting a `Struct` instance.
* 0.3.0
  * Added support for evaluating object methods.
* 0.4.0
  * Cleanup: preparing an overhaul
