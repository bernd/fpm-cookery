module FPM
  module Cookery

    # A PathSet encapsulates the path configuration of a recipe.
    class PathSet

      # Most of the path helper stuff comes from brew2deb and homebrew.
      def prefix(path = nil)
        root / install_prefix / path
      end

      def etc(path = nil)
        root / 'etc' / path
      end

      def opt(path = nil)
        root / 'opt' / path
      end

      def var(path = nil)
        root / 'var' / path
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

      attr :root, :install_prefix

      def initialize(root, install_prefix = 'usr' )
        @root = Path.new(root.to_s)
        @install_prefix = install_prefix
      end

      def rebase(new_root)
        self.class.new(new_root, install_prefix)
      end

    end
  end
end
