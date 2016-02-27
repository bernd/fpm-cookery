# Credit due to Nick Sutterer, whose +Uber::InheritableAttr+ provides much
# of the code that appears with modification here.
# @see https://github.com/apotonick/uber
# @see https://raw.githubusercontent.com/apotonick/uber/master/LICENSE

# +Uber+'s license reproduced here:
#  # Copyright (c) 2012 Nick Sutterer
#
#  MIT License
#
#  Permission is hereby granted, free of charge, to any person obtaining
#  a copy of this software and associated documentation files (the
#  "Software"), to deal in the Software without restriction, including
#  without limitation the rights to use, copy, modify, merge, publish,
#  distribute, sublicense, and/or sell copies of the Software, and to
#  permit persons to whom the Software is furnished to do so, subject to
#  the following conditions:
#
#  The above copyright notice and this permission notice shall be
#  included in all copies or substantial portions of the Software.
#
#  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
#  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
#  MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
#  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
#  LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
#  OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
#  WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

require 'fpm/cookery/path'

module FPM
  module Cookery
    # Provides inheritance of class-level attributes. Attributes are cloned
    # from the superclass, except for non-clonable attributes, which are
    # assigned directly.
    #
    # This module will automatically define class methods for keeping track of
    # inheritable attributes, as follows:
    #   +attr_rw+       => +klass.scalar_attrs+
    #   +attr_rw_list+  => +klass.list_attrs+
    #   +attr_rw_hash+  => +klass.hash_attrs+
    #   +attr_rw_path+  => +klass.path_attrs+
    #
    # @example
    #   class Foo
    #     extend FPM::Cookery::InheritableAttr
    #
    #     attr_rw       :name, :rank
    #     attr_rw_list  :favorite_things
    #     attr_rw_hash  :meta
    #     attr_rw_path  :home
    #
    #     name("J.J. Jingleheimer-Schmidt")
    #     favorite_things("brown paper packages", "raindrops on roses")
    #     meta[:data] = "la la la la la la la la"
    #     home = "/home/jjschmidt"
    #   end
    #
    #   Bar = Class.new(Foo)
    #   Bar.home                #=> #<FPM::Cookery::Path:/home/jjschmidt>
    #   Bar.home = "/home/free" #=> #<FPM::Cookery::Path:/home/free>
    #   Foo.home                #=> #<FPM::Cookery::Path:/home/jjschmidt>
    #
    #   Foo.scalar_attrs        #=> [:name, :rank]
    #   Foo.list_attrs          #=> [:favorite_things]
    #   Foo.hash_attrs          #=> [:meta]
    #   Foo.path_attrs          #=> [:home]
    module InheritableAttr
      # Adds a list of attributes keyed to the +type+ key of an internal hash
      # tracking class attributes. Also defines the method +"#{type}_attrs"+,
      # which will return the list of attribute names keyed to +type+.
      # @example
      def register_attrs(type, *attrs)
        (attr_registry[type] ||= []).concat(attrs)

        unless respond_to?(type_reader = :"#{type}_attrs")
          (class << self ; self ; end).send(:define_method, type_reader) do
            attr_registry.fetch(type, []).dup
          end
        end
      end

      # Create `scalar' (i.e. non-collection) attributes.
      def attr_rw(*attrs)
        attrs.each do |attr|
          class_eval %Q{
            def self.#{attr}(value = nil)
              if value.nil?
                return @#{attr} if instance_variable_defined?(:@#{attr})
                @#{attr} = InheritableAttr.inherit_for(self, :#{attr})
              else
                @#{attr} = value
              end
            end

            def #{attr}
              self.class.#{attr}
            end
          }
        end

        register_attrs(:scalar, *attrs)
      end

      # Create list-style attributes, backed by +Array+s. +nil+ entries will
      # be filtered, and non-unique entries will be culled to one instance
      # only.
      def attr_rw_list(*attrs)
        attrs.each do |attr|
          class_eval %Q{
            def self.#{attr}(*list)
              unless instance_variable_defined?(:@#{attr})
                @#{attr} = InheritableAttr.inherit_for(self, :#{attr})
              end

              @#{attr} ||= []
              @#{attr} << list
              @#{attr}.flatten!
              @#{attr}.uniq!
              @#{attr}
            end

            def #{attr}
              self.class.#{attr}
            end
          }
        end

        register_attrs(:list, *attrs)
      end

      # Create +Hash+-style attributes.  Supports both hash and argument
      # assignment:
      #   attr_method[:attr1] = xxxx
      #   attr_method :xxxx=>1, :yyyy=>2
      def attr_rw_hash(*attrs)
        attrs.each do |attr|
          class_eval %Q{
            def self.#{attr}(args = {})
              unless instance_variable_defined?(:@#{attr})
                @#{attr} = InheritableAttr.inherit_for(self, :#{attr})
              end

              (@#{attr} ||= {}).merge!(args)
            end

            def #{attr}
              self.class.#{attr}
            end
          }
        end

        register_attrs(:hash, *attrs)
      end

      # Create methods for attributes representing paths.  Arguments to
      # writer methods will be converted to +FPM::Cookery::Path+ objects.
      def attr_rw_path(*attrs)
        attrs.each do |attr|
          class_eval %Q{
            def self.#{attr}
              return @#{attr} if instance_variable_defined?(:@#{attr})
              @#{attr} = InheritableAttr.inherit_for(self, :#{attr})
            end

            def self.#{attr}=(value)
              @#{attr} = FPM::Cookery::Path.new(value)
            end

            def #{attr}=(value)
              self.class.#{attr} = value
            end

            def #{attr}(path = nil)
              self.class.#{attr}(path)
            end
          }
        end

        register_attrs(:path, *attrs)
      end

      class << self
        def inherit_for(klass, name)
          return unless klass.superclass.respond_to?(name)
          DeepClone.(klass.superclass.send(name))
        end

        def extended(klass)
          # Inject the +attr_registry+ attribute into any class that extends
          # this module.
          klass.attr_rw_hash(:attr_registry)
        end
      end

      # Provides deep cloning of data structures. Used in
      # +InheritableAttr.inherit_for+ to, among other things, avoid
      # accidentally propagating to the superclass changes made to
      # substructures of an attribute (such as arrays contained in a hash
      # attributes).
      class DeepClone
        def self.call(obj)
          case obj
            when Hash
              obj.class[obj.map { |k, v| [DeepClone.(k), DeepClone.(v)] }]
            when Array
              obj.map { |v| DeepClone.(v) }
            when Symbol, TrueClass, FalseClass, NilClass
              obj
            else
              obj.respond_to?(:clone) ? obj.clone : obj
          end
        end
      end
    end
  end
end
