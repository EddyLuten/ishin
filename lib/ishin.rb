require 'ishin/version'

module Ishin
  module Mixin
    def to_hash(options = {})
      Ishin.to_hash(self, options)
    end
  end

  def self.to_hash(object, options = {})
    options = defaults.merge(options)
    result = {}

    case object
    when Struct then struct_to_hash(result, object, options)
    when Hash   then hash_to_hash(result, object, options)
    else             object_to_hash(result, object, options)
    end

    evaluate_methods(result, object, options)
    result
  end

  private

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
      key = key.to_sym if options[:symbolize] && key.is_a?(String)

      result[key] = native_type?(value) ? value : to_hash(value, new_options)
    end
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
      key = instance_variable_to_key(options[:symbolize])

      if should_recurse?(options) && !native_type?(value)
        result[key] = to_hash(value, new_options)
      else
        result[key] = value
      end
    end
  end

  def self.instance_variable_to_key(symbolize)
    result = symbolize.to_s.delete('@')
    symbolize ? result.to_sym : result
  end

  def self.evaluate_methods(result, object, options)
    return if options[:evaluate].nil? || options[:evaluate].empty?

    options[:evaluate].each do |method|
      next unless object.methods.include?(method)
      key_name = options[:symbolize] ? method : method.to_s
      result[key_name] = object.send(method)
    end
  end

  def self.should_recurse?(options)
    options[:recursive] && options[:recursion_depth] > 0
  end

  def self.native_type?(value)
    [String, Numeric, TrueClass, FalseClass].any? { |i| value.is_a?(i) }
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
