require 'fpm/cookery/path'
require 'fpm/cookery/path_set'
require 'forwardable'
module FPM
  module Cookery
    module PathHelper

      def paths=(path_set)
        raise ArgumentError, "Expected a PathSet, got #{path_set.inspect}" unless path_set.kind_of? PathSet
        @paths = path_set
      end

      # Real paths on disk.
      #
      # @example
      #   recipe.paths.etc #=> "/etc"
      #   recipe.paths.bin #=> "/usr/bin"
      #   recipe.paths.var #=> "/var"
      #
      # @return [PathSet]
      def paths
        @paths ||= PathSet.new('/', 'usr')
      end

      alias real paths

      # Paths inside the temporary destination
      #
      # @example
      #   recipe.destination.etc #=> "<recipe-dir>/tmp-dst/etc"
      #   recipe.destination.bin #=> "<recipe-dir>/tmp-dst/usr/bin"
      #   recipe.destination.var #=> "<recipe-dir>/var"
      #
      # @return [PathSet]
      def destination
        paths.rebase(destdir / paths.root.to_s)
      end

      # Depending on the situation the current pathset points to 
      # the real pathset or the destination path set.
      #
      # @example
      #   recipe.installing = false
      #   recipe.current.etc         #=> "/etc"
      #   recipe.installing = true
      #   recipe.current.etc         #=> "<recipe-dir>/tmp-dst/etc"
      #
      # @return [PathSet]
      def current
        real_paths? ? real : destination
      end

      attr :installing, :omnibus_installing
      alias installing? installing
      alias omnibus_installing? omnibus_installing

      def installing=(v)
        @installing = v
      end

      def omnibus_installing=(v)
        @omnibus_installing = v
      end

      def real_paths?
        omnibus_installing? or not installing?
      end

      extend Forwardable

      delegate %w{prefix etc opt var bin doc include info lib libexec man man1 man2 man3 man4 man5 man6 man7 man8 sbin share} => :current

      # Return real paths for the scope of the given block.
      #
      # prefix('usr') # => /../software/tmp-dest/usr
      #
      # with_trueprefix do
      #   prefix('usr') # => /usr
      # end
      def with_trueprefix
        old_value = self.installing
        self.installing = false
        yield
      ensure
        self.installing = old_value
      end

      def with_paths(paths)
        old = self.paths
        self.paths = paths
        yield
      ensure
        self.paths = old
      end

    end
  end
end
