require 'spec_helper'
require 'fpm/cookery/inheritable_attr'
require 'fpm/cookery/path'

def dsl_klass(name = nil)
  (klass = Class.new).send(:extend, FPM::Cookery::InheritableAttr)
  klass.class_eval(&Proc.new) if block_given?
  klass
end

shared_examples 'attribute registration' do |attr_method, registry_method|
  context "given an attribute created with .#{attr_method}" do
    it "registers the attribute in the .#{registry_method} list" do
      klass = Class.new do
        extend FPM::Cookery::InheritableAttr

        instance_eval %Q{
          #{attr_method} :dummy_attr
        }
      end

      expect(klass).to respond_to(registry_method)
      expect(klass.send(registry_method)).to include(:dummy_attr)
    end
  end
end

shared_context 'class inheritance' do
  let(:superklass) { dsl_klass }
  let(:subklass) { Class.new(superklass) }
end

shared_examples 'attribute inheritance' do |attr_method, default_value, attr_name = :dummy_attr|
  # A default implementation.  Useful for +.attr_rw+, but should probably be
  # overridden for the other DSL methods.
  let(:attr_setter) {
    Class.new do
      def self.call(k, m, v)
        k.send(m, v)
      end
    end
  }

  describe 'created attribute' do
    it 'is defined on class' do
      expect(superklass).to respond_to(attr_name)
    end

    it "is #{default_value.inspect} by default" do
      expect(superklass.send(attr_name)).to eq(default_value)
    end

    it 'sets the attribute' do
      attr_setter.(superklass, attr_name, value)
      expect(superklass.send(attr_name)).to eq value
    end
  end

  describe 'child class' do
    describe 'inherited attribute' do
      it 'inherits its value from the superclass' do
        attr_setter.(superklass, attr_name, value)
        expect(subklass.send(attr_name)).to eq value
      end

      context 'when altered' do
        it 'does not propagate to the superclass' do
          attr_setter.(superklass, attr_name, value)
          attr_setter.(subklass, attr_name, child_value)
          expect(superklass.send(attr_name)).to eq value
        end
      end
    end
  end
end

shared_context 'inheritable attributes' do |attr_method, default_value, attr_name = :dummy_attr|
  include_context 'class inheritance'
  include_examples 'attribute inheritance', attr_method, default_value

  before(:example) do
    missing = [:value, :child_value].reject { |m| respond_to?(m) }
    raise "Missing required methods: #{missing.join(', ')}" unless missing.empty?

    superklass.instance_eval do
      send(attr_method, attr_name)
    end
  end
end

describe FPM::Cookery::InheritableAttr do
  describe 'this' do
    it 'fails' do
      puts ''
    end
  end

  describe '.register_attrs' do
    describe '.attr_rw' do
      include_examples 'attribute registration', 'attr_rw', 'scalar_attrs'
    end

    describe '.attr_rw_list' do
      include_examples 'attribute registration', 'attr_rw_list', 'list_attrs'
    end

    describe '.attr_rw_hash' do
      include_examples 'attribute registration', 'attr_rw_hash', 'hash_attrs'
    end

    describe '.attr_rw_path' do
      include_examples 'attribute registration', 'attr_rw_path', 'path_attrs'
    end
  end

  describe '.attr_rw' do
    include_context 'inheritable attributes', 'attr_rw', nil do
      let(:value) { 'that' }
      let(:child_value) { 'the other' }
    end
  end

  describe '.attr_rw_list' do
    include_context 'inheritable attributes', 'attr_rw_list', [] do
      let(:attr_setter) {
        Class.new do
          def self.call(k, m, v)
            k.send(m, *v)
          end
        end
      }

      let(:value) { %w{so la ti do} }
      let(:child_value) { %w{fee fi fo fum} }
    end
  end

  describe '.attr_rw_hash' do
    include_context 'inheritable attributes', 'attr_rw_hash', {} do
      let(:value) { {:name => 'mike', :rank => 'colonel' } }
      let(:child_value) { {:name => 'mike', :favorite_color => 'puce' } }
    end

    describe 'created attribute' do
      before do
        superklass.instance_eval do
          attr_rw_hash :metadata
        end

        superklass.metadata({ :radius => 4.172, :weight => 4 })
      end

      it 'merges its argument into the existing attribute value' do
        superklass.metadata({ :weight => 7, :height => 12.3 })
        expect(superklass.metadata).to eq({
          :height => 12.3,
          :weight => 7,
          :radius => 4.172
        })
      end

      it 'supports []= assignment' do
        expect { superklass.metadata[:age] = 10000 }.not_to raise_error
        expect(superklass.metadata).to include(:age => 10000)
      end

      context 'from child class' do
        it 'does not propagate changes to the parent class' do
          superklass.metadata[:tags] = %w{a b c}
          subklass.metadata[:tags] << 'd'
          expect(superklass.metadata[:tags]).not_to include('d')
        end
      end
    end
  end

  describe '.attr_rw_path' do
    include_context 'inheritable attributes', 'attr_rw_path', nil do
      let(:attr_setter) {
        Class.new do
          def self.call(k, m, v)
            k.send(:"#{m}=", v)
          end
        end
      }

      let(:value) { FPM::Cookery::Path.new('/var/spool') }
      let(:child_value) { FPM::Cookery::Path.new('/proc/self') }
    end

    it 'returns an FPM::Cookery::Path object' do
      superklass.attr_rw_path :home
      superklass.home = "/where/the/heart/is"
      expect(superklass.home).to be_an(FPM::Cookery::Path)
    end
  end

  describe '.inherit_for' do
    include_context 'class inheritance'

    context 'given a method name that the superclass does not respond to' do
      it 'returns nil' do
        expect(superklass).not_to respond_to(:blech)
        expect(FPM::Cookery::InheritableAttr.inherit_for(subklass, :blech)).to be nil
      end
    end
  end
end
