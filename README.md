[![Code Climate](https://codeclimate.com/github/EddyLuten/ishin/badges/gpa.svg)](https://codeclimate.com/github/EddyLuten/ishin) [![Gem Version](https://img.shields.io/gem/v/ishin.svg)](https://rubygems.org/gems/ishin)

# Ishin

Ishin converts Ruby objects into their Hash representations. It works with plain old classes, extended classes, classes with mixins, and hashes (see Usage for more on that).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'ishin'
```

And then execute:

    bundle

Or install it manually by:

    gem install ishin

## Usage

```ruby
require 'ishin'

hash = Ishin.to_hash(my_object)
```

### Introduction

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

Ishin also handles object instances nested within other object instances. By default, recursive hash conversion is turned off. To enable recursion, set the `recursive` option to `true`:

```ruby
test_struct = Struct.new(:value)
nested_structs = test_struct.new(test_struct.new('value'))


Ishin.to_hash(nested_structs, recursive: true)
# => {:value=>{:value=>"value"}}
```

### Recursion Depth

For deeply nested object instances, a maximum recursion depth can be provided in combination with the `recursive` option. The default recursion depth is one (initial call + 1).

```ruby
nest_me = Struct.new(:value)
deep_nesting = nest_me.new(nest_me.new(nest_me.new(nest_me.new('such depth'))))

Ishin.to_hash(deep_nesting, recursive: true, recursion_depth: 2)
# => {:value=>{:value=>{:value=>#<struct value="such depth">}}}
```

Notice in the above example that the recursion stopped after 3 steps (initial call + 2).

### Expanding Hashes using Recursion

Using recursion, it is also possible to convert hashes containing object instances to a hash-only representation as well. Notice that this only works if the `recursive` option is provided.

```ruby
another_struct = Struct.new(:value)
my_hash = {
  my_struct: another_struct.new("yup, it's a struct")
}

Ishin.to_hash(my_hash, recursive: true)
# => {:my_struct=>{:value=>"yup, it's a struct"}}
```

Keep in mind that the `recursive` option works in conjunction with the `recursion_depth` option.

### Symbolizing Keys

By default, Ishin stores key names as symbols. This behavior can be disabled by setting the `symbolize` option to `false`.

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
When setting the `symbolize` option to `false`, the explicit conversion of strings to symbols is prevented. This, however, does *not* mean that hashes whose keys are already symbols are converted into string-based keys.

## Running the Specs

Once `bundle` is executed, simply run:

    rake spec
