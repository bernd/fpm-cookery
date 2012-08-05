require 'pathname'
require 'fileutils'

module FPM
  module Cookery
    class Path < Pathname
      if '1.9' <= RUBY_VERSION
        alias_method :to_str, :to_s
      end

      def self.pwd(path = nil)
        new(Dir.pwd)/path
      end

      def +(other)
        other = Path.new(other) unless Path === other
        Path.new(plus(@path, other.to_s))
      end

      def /(path)
        self + (path || '').gsub(%r{^/}, '')
      end

      def mkdir
        FileUtils.mkdir_p(self.to_s)
      end

      def install(src, new_basename = nil)
        case src
        when Array
          src.collect {|src| install_p(src) }
        when Hash
          src.collect {|src, new_basename| install_p(src, new_basename) }
        else
          install_p(src, new_basename)
        end
      end

      # @deprecated Will be made private in the future.
      # @private
      def install_p(src, new_basename = nil)
        if new_basename
          new_basename = File.basename(new_basename) # rationale: see Pathname.+
          dst = self/new_basename
          return_value = Path.new(dst)
        else
          dst = self
          return_value = self/File.basename(src)
        end

        src = src.to_s
        dst = dst.to_s

        # if it's a symlink, don't resolve it to a file because if we are moving
        # files one by one, it's likely we will break the symlink by moving what
        # it points to before we move it
        # and also broken symlinks are not the end of the world
        raise "#{src} does not exist" unless File.symlink? src or File.exist? src

        mkpath
        FileUtils.cp_r src, dst, :preserve => true

        # if File.symlink? src
        #   # we use the BSD mv command because FileUtils copies the target and
        #   # not the link! I'm beginning to wish I'd used Python quite honestly!
        #   raise unless Kernel.system 'mv', src, dst
        # else
        #   # we mv when possible as it is faster and you should only be using
        #   # this function when installing from the temporary build directory
        #   FileUtils.mv src, dst
        # end

        return return_value
      end
    end
  end
end
