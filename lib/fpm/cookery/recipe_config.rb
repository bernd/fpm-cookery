require 'erb'
require 'yaml'

module FPM
  module Cookery
    # This class is meant to deal with missing variables or methods called
    # within an embedded ruby template.  By storing template variables in an
    # instance variable hash, and by setting the 'method_missing' handler to a
    # lookup of this hash, any non-existing variable or method will be set to
    # 'nil' within the template.
    class ErbInject
      def initialize(hash)
        @hash = hash.dup
      end

      def method_missing(meth, *args, &block)
        @hash[meth.to_sym]
      end

      def get_binding
        binding
      end
    end

    # This class interprets YAML documents, optionally containing
    # embedded ruby, and returns their contents as a hash.  By using the
    # ErbInject class, above, it avoids erroring out on missing variables or
    # methods, enabling keys of the interpreted hash to be interpolated into
    # the template.
    class RecipeConfig
      def RecipeConfig.load(data)
        hash = YAML.load(data)
        injected = ErbInject.new(hash)
        template = ERB.new(data)
        parsed = template.result(injected.get_binding)

        # Simple recursion - if an 'injected' value contains embedded ruby,
        # pass it through this method again until no embedded ruby is left.
        if /<%.*?%>/m.match(parsed)
          RecipeConfig.load(parsed)
        else
          YAML.load(parsed)
        end
      end

      def RecipeConfig.load_file(path)
        data = File.read(path)
        RecipeConfig.load(data)
      end
    end
  end
end
