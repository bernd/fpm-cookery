module FPM
  module Cookery
    module Utils
      protected
      # From fpm. (lib/fpm/util.rb)
      def safesystem(*args)
        success = system(*args.flatten)
        if !success
          raise "'system(#{args.inspect})' failed with error code: #{$?.exitstatus}"
        end
        return success
      end

      def cleanenv_safesystem(*args)
        bundler_vars = %w(BUNDLE_GEMFILE RUBYOPT BUNDLE_BIN_PATH GEM_HOME GEM_PATH)
        bundled_env = ENV.to_hash
        bundler_vars.each {|var| ENV.delete(var)}
        result = safesystem(*args)
        ENV.replace(bundled_env.to_hash)
        result
      end

      # From brew2deb. (lib/debian_formula.rb)
      def configure(*args)
        if args.last.is_a?(Hash)
          opts = args.pop
          args += opts.map{ |k,v|
            option = k.to_s.gsub('_','-')
            if v == true
              "--#{option}"
            else
              "--#{option}=#{v}"
            end
          }
        end

        safesystem './configure', *args
      end

      # From brew2deb. (lib/debian_formula.rb)
      def make(*args)
        env = args.pop if args.last.is_a?(Hash)
        env ||= {}

        args += env.map{ |k,v| "#{k}=#{v}" }
        args.map!{ |a| a.to_s }

        safesystem 'make', *args
      end

      # From homebrew. (Library/Homebrew/utils.rb)
      def inline_replace(path, before = nil, after = nil)
        [*path].each do |path|
          f = File.open(path, 'r')
          s = f.read

          if before == nil and after == nil
            # s.extend(StringInreplaceExtension)
            yield s
          else
            s.gsub!(before, after)
          end

          f.reopen(path, 'w').write(s)
          f.close
        end
      end
      alias_method :inreplace, :inline_replace # homebrew compat

      def patch(src, level = 0)
        raise "patch level must be integer" unless level.is_a?(Fixnum)
        raise "#{src} does not exist" unless File.exist? src
        safesystem "patch -p#{level} --batch < #{src}"
      end
    end
  end
end
