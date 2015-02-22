require 'erb'
require 'yaml'

module FPM
  module Cookery
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

    class RecipeConfig
      def RecipeConfig.load(data)
        hash = YAML.load(data)
        injected = ErbInject.new(hash)
        template = ERB.new(data)
        parsed = template.result(injected.get_binding)

        # Simple recursion - if an 'injected' value contains embedded ruby,
        # pass it through this method again until no embedded ruby is left.
        if /<%.*%>/.match(parsed)
          RecipeConfig.load(parsed)
        else
          YAML.load(parsed)
        end
      end

      def RecipeConfig.load_file(paths)
        path = Array(paths).find {|p| File.exist?(p) }
        data = File.read(path)
        RecipeConfig.load(data)
      end
    end
  end
end
