require 'ishin/version'

module Ishin

  module Mixin
    def to_hash options = {}
      Ishin::to_hash(self, options)
    end
  end

  def self.to_hash(object, options = {})
    options = defaults.merge(options)
    result = {}

    case object
    when Struct
      struct_to_hash(result, object, options)
    when Hash
      hash_to_hash(result, object, options)
    else
      object_to_hash(result, object, options)
    end

    result
  end

  private

  def self.decrement_recursion_depth(options)
    options[:recursion_depth] = [0, options[:recursion_depth] - 1].max
    options
  end

  def self.assign_value(result, key, value, options, new_options)
    result[key] = should_recurse?(options, value) ? to_hash(value, new_options) : value
  end

  def self.hash_to_hash(result, object, options)
    return result.replace(object) unless options[:recursive]

    new_options = decrement_recursion_depth(options.clone)

    object.each do |key, value|
      key = key.to_sym if options[:symbolize] && key.is_a?(String)
      assign_value(result, key, value, options, new_options)
    end
  end

  def self.struct_to_hash result, object, options
    new_options = decrement_recursion_depth options.clone

    object.members.each do |member|
      key = options[:symbolize] ? member : member.to_s
      value = object[member]
      assign_value(result, key, value, options, new_options)
    end
  end

  def self.object_to_hash(result, object, options)
    new_options = decrement_recursion_depth(options.clone)

    object.instance_variables.each do |var|
      value = object.instance_variable_get(var)
      key = var.to_s.delete('@')
      key = key.to_sym if options[:symbolize]
      assign_value(result, key, value, options, new_options)
    end
  end

  def self.should_recurse? options, value
    options[:recursive] && options[:recursion_depth] > 0 && !is_native_type?(value)
  end

  def self.is_native_type? value
    [ String, Numeric, TrueClass, FalseClass ].any? { |i| value.is_a?(i) }
  end

  def self.defaults
    {
      recursive: false,
      recursion_depth: 1,
      symbolize: true
    }
  end
end
