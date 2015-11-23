require 'spec_helper'

describe Ishin do
  let(:simple_class) { SimpleClass.new('class value') }

  context 'version number' do
    it { expect(Ishin::Version::MAJOR).to be_a(String) }
    it { expect(Ishin::Version::MINOR).to be_a(String) }
    it { expect(Ishin::Version::PATCH).to be_a(String) }
    it { expect(Ishin::Version::STRING).to be_a(String) }
  end

  context '#to_hash' do
    let(:class_variable) { HasClassVariable.new }
    let(:tiny_hash) { { x: true } }
    let(:string_hash) { { 'x' => true } }
    let(:complex_class) { ComplexClass.new }

    context 'native type -> hash' do
      it 'converts a Numeric type to an empty hash' do
        expect(Ishin.to_hash(1)).to eq({})
      end

      it 'converts a String to an empty hash' do
        expect(Ishin.to_hash('test')).to eq({})
      end

      it 'converts an Object to an empty hash' do
        expect(Ishin.to_hash(Object.new)).to eq({})
      end

      it 'converts the Boolean "true" to an empty hash' do
        expect(Ishin.to_hash(true)).to eq({})
      end

      it 'converts the Boolean "false" to an empty hash' do
        expect(Ishin.to_hash(false)).to eq({})
      end
    end

    context 'struct -> hash' do
      it 'converts a struct instance without options provided' do
        obj = SimpleStruct.new('value')
        expect(Ishin.to_hash(obj)).to eq(test: 'value')
      end

      it 'converts a struct instance and does not recurse' do
        obj = SimpleStruct.new(SimpleStruct.new('value'))
        result = Ishin.to_hash(obj)

        expect(result[:test]).to be_a(SimpleStruct)
        expect(result[:test][:test]).to eq('value')
      end

      it 'converts a struct instance recursively' do
        obj = SimpleStruct.new(SimpleStruct.new('value'))
        result = Ishin.to_hash(obj, recursive: true)

        expect(result).to eq(test: { test: 'value' })
      end

      it 'converts, recursion_depth > required recursion has no effect' do
        obj = SimpleStruct.new(SimpleStruct.new('value'))
        result = Ishin.to_hash(obj, recursive: true, recursion_depth: 5000)

        expect(result).to eq(test: { test: 'value' })
      end

      it 'converts a struct instance recursively to the set recursion depth' do
        obj = SimpleStruct.new(SimpleStruct.new(SimpleStruct.new('value')))
        result = Ishin.to_hash(obj, recursive: true, recursion_depth: 1)

        expect(result).to eq(
          test: {
            test: SimpleStruct.new('value')
          }
        )
      end

      it 'converts a struct containing class instances recursively' do
        obj = SimpleStruct.new(simple_class)
        result = Ishin.to_hash(obj, recursive: true)

        expect(result).to eq(test: { test: 'class value' })
      end
    end

    context 'object -> hash' do
      it 'converts a class instance without options provided' do
        expect(Ishin.to_hash(simple_class)).to eq(test: 'class value')
      end

      it 'converts an object but does not symbolize the names' do
        expect(Ishin.to_hash(simple_class, symbolize: false)).to eq(
          'test' => 'class value'
        )
      end

      it 'does not convert class variables' do
        expect(Ishin.to_hash(class_variable)).to eq(only_this: 'value')
      end
    end

    context 'hash -> hash' do
      it 'does not convert the hash without options provided' do
        expect(Ishin.to_hash(tiny_hash)).to eq(tiny_hash)
      end

      it 'converts the hash if recursion is turned on' do
        obj = { x: simple_class }
        result = Ishin.to_hash(obj, recursive: true)

        expect(result).to eq(x: { test: 'class value' })
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
        expect(Ishin.to_hash(complex_class)).to eq(
          something: 'parent value',
          anything: 'child value',
          nothing: 'mixin value'
        )
      end
    end

    context 'method evaluation' do
      let(:dog) { Dog.new }
      let(:speaker) { Speaker.new }

      it 'evaluates methods correctly' do
        options = { evaluate: [:blurb] }

        expect(Ishin.to_hash(dog, options)).to eq(
          blurb: 'I am a Dog, My species is Canis Lupus, My genus is Lupus.'
        )
      end

      it 'does not evaluate methods by default' do
        expect(Ishin.to_hash(dog)).to be_empty
      end

      it 'does not symbolize method names when symbolize is false' do
        options = { evaluate: [:blurb], symbolize: false }

        expect(Ishin.to_hash(dog, options)).to eq(
          'blurb' => 'I am a Dog, My species is Canis Lupus, My genus is Lupus.'
        )
      end

      it 'does not blow up when a bad method name was provided' do
        options = { evaluate: [:bark] }
        expect(Ishin.to_hash(dog, options)).to be_empty
      end

      it 'raises when evaluating a method requiring parameters' do
        options = { evaluate: [:speak] }
        expect { Ishin.to_hash(speaker, options) }.to raise_error(ArgumentError)
      end

      it 'does not raise when evaluating methods with optional parameters' do
        options = { evaluate: [:say] }
        expect(Ishin.to_hash(speaker, options)).to eq(say: 'Say what?')
      end
    end
  end

  context 'Mixin' do
    let(:mixed_in) { MixedInClass.new }
    let(:wont_override) { WontOverrideMixinClass.new }
    let(:extended_mixed_in) { ExtendedMixedInClass.new }
    let(:recursive) { MixedInForRecursion.new }
    let(:deep) { MixedInDeepRecursion.new }

    it 'provides a working to_hash method when mixed in' do
      expect(mixed_in.to_hash).to eq(key: 'value')
    end

    it 'will not override any existing to_hash method' do
      expect(wont_override.to_hash).to eq(existing: true)
    end

    it 'can be overridden if the mixedin class is extended' do
      expect(extended_mixed_in.to_hash).to eq(key: 'value', merged: true)
    end

    it 'accepts the recursive option' do
      result = recursive.to_hash(recursive: true)
      expect(result).to eq(value: { test: 'recursive' })
    end

    it 'accepts the recursion_depth option' do
      result = deep.to_hash(recursive: true, recursion_depth: 3)
      expect(result).to eq(value: { test: { test: { test: 'deep' } } })
    end

    it 'accepts the symbolize option' do
      expect(mixed_in.to_hash(symbolize: false)).to eq('key' => 'value')
    end
  end
end
