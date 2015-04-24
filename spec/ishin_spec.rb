require 'spec_helper'

describe Ishin do
  it 'has a version number' do
    expect(Ishin::VERSION).not_to be nil
  end

  context '#to_hash' do
    let(:simple_struct) { Struct.new(:test) }
    let(:simple_class) { SimpleClass.new('class value') }
    let(:class_variable) { HasClassVariable.new }
    let(:tiny_hash) {{ x: true }}
    let(:string_hash) {{ 'x' => true }}
    let(:complex_class) { ComplexClass.new }

    context 'native type -> hash' do
      it 'converts a Numeric type to an empty hash' do
        expect(Ishin.to_hash 1).to eq({})
      end

      it 'converts a String to an empty hash' do
        expect(Ishin.to_hash 'test').to eq({})
      end

      it 'converts an Object to an empty hash' do
        expect(Ishin.to_hash Object.new).to eq({})
      end

      it 'converts the Boolean "true" to an empty hash' do
        expect(Ishin.to_hash true).to eq({})
      end

      it 'converts the Boolean "false" to an empty hash' do
        expect(Ishin.to_hash false).to eq({})
      end
    end

    context 'struct -> hash' do
      it 'converts a struct instance without options provided' do
        obj = simple_struct.new('value')
        expect(Ishin.to_hash obj).to eq({ test: 'value' })
      end

      it 'converts a struct instance and does not recurse' do
        obj = simple_struct.new(simple_struct.new('value'))
        result = Ishin.to_hash obj

        expect(result[:test]).to be_a(simple_struct)
        expect(result[:test][:test]).to eq('value')
      end

      it 'converts a struct instance recursively' do
        obj = simple_struct.new(simple_struct.new('value'))
        result = Ishin.to_hash obj, recursive: true

        expect(result).to eq({
          test: {
            test: 'value'
          }
        })
      end

      it 'converts, recursion_depth > required recursion has no effect' do
        obj = simple_struct.new(simple_struct.new('value'))
        result = Ishin.to_hash obj, recursive: true, recursion_depth: 5000

        expect(result).to eq({
          test: {
            test: 'value'
          }
        })
      end

      it 'converts a struct instance recursively to the set recursion depth' do
        obj = simple_struct.new(simple_struct.new(simple_struct.new('value')))
        result = Ishin.to_hash obj, recursive: true, recursion_depth: 1

        expect(result).to eq(
          test: {
            test: simple_struct.new('value')
          }
        )
      end

      it 'converts a struct containing class instances recursively' do
        obj = simple_struct.new(simple_class)
        result = Ishin.to_hash obj, recursive: true

        expect(result).to eq({
          test: {
            test: 'class value'
          }
        })
      end

      it 'converts a struct instance recursively and does not symbolize the names' do
        obj = simple_struct.new(simple_struct.new(simple_struct.new('value')))
        result = Ishin.to_hash obj, recursive: true, recursion_depth: 3, symbolize: false

        expect(result).to eq({
          'test' => {
            'test' => {
              'test' => 'value'
            }
          }
        })
      end
    end

    context 'object -> hash' do
      it 'converts a class instance without options provided' do
        expect(Ishin.to_hash simple_class).to eq({ test: 'class value' })
      end

      it 'converts an object but does not symbolize the names' do
        expect(Ishin.to_hash simple_class, symbolize: false).to eq({ 'test' => 'class value' })
      end

      it 'does not convert class variables' do
        expect(Ishin.to_hash class_variable).to eq({
          only_this: 'value'
        })
      end
    end

    context 'hash -> hash' do
      it 'does not convert the hash without options provided' do
        expect(Ishin.to_hash tiny_hash).to eq(tiny_hash)
      end

      it 'converts the hash if recursion is turned on' do
        obj = { x: simple_class }
        result = Ishin.to_hash obj, recursive: true

        expect(result).to eq({ x: { test: 'class value' } })
      end

      it 'symbolizes the hash\'s string keys if they were strings' do
        expect(Ishin.to_hash(string_hash, recursive: true)).to eq(tiny_hash)
      end

      it 'does not symbolize the hash\'s string keys when symbolize is false' do
        result = Ishin.to_hash(string_hash, recursive: true, symbolize: false)

        expect(result).to eq(string_hash)
      end
    end

    context 'complex -> hash' do
      it 'can convert a complex extended and mixin object' do
        expect(Ishin.to_hash(complex_class)).to eq({
          something: 'parent value',
          anything: 'child value',
          nothing: 'mixin value'
        })
      end
    end
  end
end
