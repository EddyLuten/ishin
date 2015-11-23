require 'ishin/version'
require 'ishin/mixin'

# Ishin is an object to hash converter Ruby Gem
module Ishin
  # Converts objects into their hash representations.
  # @param object [Object] an object to convert
  # @param options [Hash] a hash containing conversion options
  def self.to_hash(object, options = {})
    options = defaults.merge(options)
    result = {}
    type_to_hash(result, object, options)
    evaluate_methods(result, object, options)
    result
  end

  private

  def self.type_to_hash(result, object, options)
    case object
    when Struct then struct_to_hash(result, object, options)
    when Hash   then hash_to_hash(result, object, options)
    else             object_to_hash(result, object, options)
    end
  end

  def self.decrement_recursion_depth(options)
    options[:recursion_depth] = [0, options[:recursion_depth] - 1].max
    options
  end

  def self.hash_to_hash(result, object, options)
    if !should_recurse?(options) && options[:symbolize]
      return result.replace(object)
    end

    new_options = decrement_recursion_depth(options.clone)

    object.each do |key, value|
      result[hash_key(key, options)] = hash_value(value, new_options)
    end
  end

  def self.hash_key(key, options)
    options[:symbolize] && key.is_a?(String) ? key.to_sym : key
  end

  def self.hash_value(value, new_options)
    native_type?(value) ? value : to_hash(value, new_options)
  end

  def self.struct_to_hash(result, object, options)
    result.replace(object.to_h)
    return unless should_recurse?(options)

    new_options = decrement_recursion_depth(options.clone)

    result.each do |key, value|
      result[key] = to_hash(value, new_options) unless native_type?(value)
    end
  end

  def self.object_to_hash(result, object, options)
    new_options = decrement_recursion_depth(options.clone)

    object.instance_variables.each do |var|
      value = object.instance_variable_get(var)
      key = instance_variable_to_key(var, options)
      result[key] = object_value(value, options, new_options)
    end
  end

  def self.instance_variable_to_key(instance_variable, options)
    key = instance_variable.to_s.delete('@')
    options[:symbolize] ? key.to_sym : key
  end

  def self.object_value(value, options, new_options)
    if should_recurse?(options) && !native_type?(value)
      to_hash(value, new_options)
    else
      value
    end
  end

  def self.evaluate_methods(result, object, options)
    evaluate = options[:evaluate]
    return if !evaluate || evaluate.empty?

    evaluate.each do |method|
      if object.methods.include?(method)
        result[method_name_to_key(method, options)] = object.send(method)
      end
    end
  end

  def self.method_name_to_key(method, options)
    options[:symbolize] ? method : method.to_s
  end

  def self.should_recurse?(options)
    options[:recursive] && options[:recursion_depth] > 0
  end

  def self.native_type?(value)
    [String, Numeric, TrueClass, FalseClass].any? { |type| value.is_a?(type) }
  end

  def self.defaults
    {
      recursive: false,
      recursion_depth: 1,
      symbolize: true,
      evaluate: [],
      exclude: []
    }
  end
end
