require 'fpm/cookery/path'

module FPM
  module Cookery
    module PathHelper
      attr_accessor :installing, :omnibus_installing

      def installing?
        installing
      end

      def omnibus_installing?
        omnibus_installing
      end

      # Most of the path helper stuff comes from brew2deb and homebrew.
      def prefix(path = nil)
        current_pathname_for('usr')/path
      end

      def etc(path = nil)
        current_pathname_for('etc')/path
      end

      def opt(path = nil)
        current_pathname_for('opt')/path
      end

      def var(path = nil)
        current_pathname_for('var')/path
      end

      def bin(path = nil)     prefix/'bin'/path            end
      def doc(path = nil)     prefix/'share/doc'/path      end
      def include(path = nil) prefix/'include'/path        end
      def info(path = nil)    prefix/'share/info'/path     end
      def lib(path = nil)     prefix/'lib'/path            end
      def libexec(path = nil) prefix/'libexec'/path        end
      def man(path = nil)     prefix/'share/man'/path      end
      def man1(path = nil)    man/'man1'/path              end
      def man2(path = nil)    man/'man2'/path              end
      def man3(path = nil)    man/'man3'/path              end
      def man4(path = nil)    man/'man4'/path              end
      def man5(path = nil)    man/'man5'/path              end
      def man6(path = nil)    man/'man6'/path              end
      def man7(path = nil)    man/'man7'/path              end
      def man8(path = nil)    man/'man8'/path              end
      def sbin(path = nil)    prefix/'sbin'/path           end
      def share(path = nil)   prefix/'share'/path          end

      # Return real paths for the scope of the given block.
      #
      # prefix('usr') # => /../software/tmp-dest/usr
      #
      # with_trueprefix do
      #   prefix('usr') # => /usr
      # end
      def with_trueprefix
        old_value = installing
        self.installing = false
        yield
      ensure
        self.installing = old_value
      end

      private
      def current_pathname_for(dir)
        if omnibus_installing?
          Path.new("/#{dir}")
        else
          installing? ? destdir/dir : Path.new("/#{dir}")
        end
      end
    end
  end
end
