require 'forwardable'
require 'fileutils'
require 'fpm/cookery/facts'
require 'fpm/cookery/hiera'
require 'fpm/cookery/source'
require 'fpm/cookery/source_handler'
require 'fpm/cookery/utils'
require 'fpm/cookery/path_helper'
require 'fpm/cookery/environment'
require 'fpm/cookery/lifecycle_hooks'
require 'fpm/cookery/log'
require 'fpm/cookery/package/cpan'
require 'fpm/cookery/package/dir'
require 'fpm/cookery/package/gem'
require 'fpm/cookery/package/npm'
require 'fpm/cookery/package/pear'
require 'fpm/cookery/package/python'
require 'fpm/cookery/package/virtualenv'
require 'fpm/cookery/log'

module FPM
  module Cookery
    class BaseRecipe
      include FileUtils
      include FPM::Cookery::Utils
      include FPM::Cookery::PathHelper
      include FPM::Cookery::LifecycleHooks

      SCALAR_ATTRIBUTES = [:arch, :description, :homepage, :maintainer, :md5,
                           :name, :revision, :section, :sha1, :sha256, :spec,
                           :vendor, :version, :pre_install, :post_install,
                           :pre_uninstall, :post_uninstall, :license,
                           :omnibus_package, :omnibus_dir, :chain_package,
                           :default_prefix].freeze

      LIST_ATTRIBUTES = [:build_depends, :config_files, :conflicts, :depends,
                         :exclude, :patches, :provides, :replaces,
                         :omnibus_recipes, :omnibus_additional_paths,
                         :chain_recipes, :directories].freeze

      HASH_ATTRIBUTES = [:fpm_attributes, :environment].freeze

      PATH_ATTRIBUTES = [:workdir, :tmp_root, :destdir, :builddir, :pkgdir,
                         :cachedir, :datadir].freeze

      class << self
        def inherited(klass)
          super
          # Apply class data inheritable pattern to @fpm_attributes class
          # variable.
          klass.instance_variable_set(:@fpm_attributes, self.fpm_attributes.dup)
          klass.instance_variable_set(:@environment, self.environment.dup)
        end

        # Create "scalar" attributes.
        def attr_rw(*attrs)
          attrs.each do |attr|
            class_eval %Q{
              def self.#{attr}(value = nil)
                value.nil? ? @#{attr} : @#{attr} = value
              end

              def #{attr}
                self.class.#{attr}
              end
            }
          end
        end

        # Create list-style attributes, backed by +Array+s.  +nil+ entries will
        # be filtered, and non-unique entries will be culled to one instance
        # only.
        def attr_rw_list(*attrs)
          attrs.each do |attr|
            class_eval %Q{
              def self.#{attr}(*list)
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
        end

        # Create +Hash+-style attributes.  Supports both hash and argument
        # assignment:
        #   attr_method[:attr1] = xxxx
        #   attr_method :xxxx=>1, :yyyy=>2
        def attr_rw_hash(*attrs)
          attrs.each do |attr|
            class_eval %Q{
              def self.#{attr}(args=nil)
                if args.is_a?(Hash)
                  @#{attr}.merge!(args)
                end

                @#{attr}
              end

              def #{attr}
                self.class.#{attr}
              end
            }
          end
        end

        # Create methods for attributes representing paths.  Arguments to
        # writer methods will be converted to +FPM::Cookery::Path+ objects.
        # Note: no class-level reader methods are defined here; they are
        # instead defined manually (see +.workdir+ and friends).
        def attr_rw_path(*attrs)
          attrs.each do |attr|
            class_eval %Q{
              def self.#{attr}=(value)
                @#{attr} = Path.new(value)
              end
            }

            class_eval %Q{
              def #{attr}=(value)
                self.class.#{attr} = value
              end
            }

            class_eval %Q{
              def #{attr}(path = nil)
                self.class.#{attr}(path)
              end
            }
          end
        end

        # Make sure that +Recipe+ classes responds to these methods, but issue
        # an exception to inform the caller that they are expected to define
        # them.
        [:filename, :config].each do |m|
          define_method m do
            raise "`.#{__method__}' must be defined when recipe file is loaded"
          end
        end

        def platforms(valid_platforms)
          Array(valid_platforms).member?(self.platform) and block_given? ? yield : false
        end

        def architectures(archs)
          Array(archs).member?(FPM::Cookery::Facts.arch) and block_given? ? yield : false
        end

        def platform
          FPM::Cookery::Facts.platform
        end

        def depends_all
          (depends + build_depends).uniq
        end

        def workdir(path = nil)
          (@workdir  ||= Path.new(filename).dirname)/path
        end

        def tmp_root(path = nil)
          (@tmp_root ||= config.tmp_root ? Path.new(config.tmp_root) : workdir)/path
        end

        def pkgdir(path = nil)
          (@pkgdir ||= config.pkg_dir ? Path.new(config.pkg_dir) : workdir('pkg'))/path
        end

        def cachedir(path = nil)
          (@cachedir ||= config.cache_dir ? Path.new(config.cache_dir) : workdir('cache'))/path
        end

        def datadir(path = nil)
          (@datadir ||= config.data_dir ? Path.new(config.data_dir) : workdir('config'))/path
        end

        def destdir(path = nil)
          (@destdir ||= tmp_root('tmp-dest'))/path
        end

        def builddir(path = nil)
          (@builddir ||= tmp_root('tmp-build'))/path
        end
      end

      @fpm_attributes = {}
      @environment = FPM::Cookery::Environment.new

      attr_rw(*SCALAR_ATTRIBUTES)
      attr_rw_list(*LIST_ATTRIBUTES)
      attr_rw_hash(*HASH_ATTRIBUTES)
      attr_rw_path(*PATH_ATTRIBUTES)

      # Resolve dependencies from omnibus package.
      def depends_all
        pkg_depends = self.class.depends_all
        if self.class.omnibus_package
          self.class.omnibus_recipes.each { |omni_recipe|
            recipe_file = File.expand_path(omni_recipe + '.rb', File.dirname(filename))

            Book.instance.load_recipe(recipe_file, config) do |recipe|
              pkg_depends << recipe.depends_all
            end
          }
        end

        pkg_depends.flatten.uniq
      end

      extend Forwardable
      # Delegate to class methods
      def_instance_delegators :'self.class', :config, :filename
    end

    class Recipe < BaseRecipe
      # Want +.source+ (which is defined here and not inherited from
      # +BaseRecipe+) to be settable from Hiera data files, too.
      const_set(:LIST_ATTRIBUTES, LIST_ATTRIBUTES.dup << :source).freeze

      def input(config)
        FPM::Cookery::Package::Dir.new(self, config)
      end

      def source_handler
        @source_handler ||= SourceHandler.new(Source.new(source, spec), cachedir, builddir)
      end

      def initialize(defer_application = false)
        # Note: this must be called prior to instantiating the +SourceHandler+,
        # so that +source+ can be picked up if it is defined in a +Hiera+ #
        # data file.
        apply unless defer_application
      end

      class << self
        def inherited(klass)
          super

          # Reset :@hiera so that it will be reinitialized for the child class
          klass.instance_variable_set(:@hiera, nil)
        end

        def source(source = nil, spec = {})
          return @source if source.nil?
          @source = source
          @spec = spec
        end
        alias_method :url, :source

        def extracted_source(path = nil)
          return @extracted_source if path.nil?
          @extracted_source = path
        end

        def hiera
          if !defined?(@hiera) or @hiera.nil?
            begin
              @hiera = FPM::Cookery::Hiera::Instance.new(self, :config => hiera_config)
            rescue StandardError => e
              error_message = "Encountered error loading Hiera: #{e.message}"
              Log.fatal error_message
              raise Error::ExecutionFailure, error_message
            end
          end

          @hiera
        end

        # Iterates over all of the +*_ATTRIBUTES+ constants, calling the
        # relevant setter methods for all attributes which return non-+nil+
        # results for +.lookup+.
        # Note: Hiera does not provide access to a structure that represents
        # the merged contents of all data files; interaction with the data must
        # go through one channel, the +.lookup+ method.  That is why we have to
        # iterate over all of these attributes, rather than loading the data
        # files into a hash and then calling only those methods for which a
        # key-value pair is specified.
        def apply
          self::SCALAR_ATTRIBUTES.each  { |m| applicator(m) { |r| send(m, r) } }
          self::LIST_ATTRIBUTES.each    { |m| applicator(m) { |r| send(m, *r) } }
          self::HASH_ATTRIBUTES.each    { |m| applicator(m) { |r| send(m).merge!(r) } }
          self::PATH_ATTRIBUTES.each    { |m| applicator(m) { |r| send("#{m}=", r) } }
        end

        private
        def hiera_hierarchy
          hiera_hierarchy = (from_env = ENV['FPM_HIERARCHY']).nil? ? [] : from_env.split(':')
          (hiera_hierarchy + [config.platform.to_s, config.target.to_s, 'common']).compact
        end

        def hiera_config
          # Note: +Hiera.new+ takes either a hash of options (with the sole
          # top-level key +:options+) or a string representing the path to a
          # configuration file.  If the `--hiera-config' flag was seen, return
          # that; otherwise, construct a hash of sane defaults.
          config.hiera_config || {
            :yaml       => { :datadir  => datadir.to_s },
            :json       => { :datadir  => datadir.to_s },
            :hierarchy  => hiera_hierarchy
          }
        end

        def applicator(method)
          if (result = lookup(method)).nil?
            Log.debug("No result for `#{method}'")
            return
          end

          Log.debug("Setting `#{method}' to `#{result}'")
          Proc.new.call(result)
        end
      end

      def sourcedir=(sourcedir)
        @sourcedir = sourcedir
      end

      attr_reader :sourcedir

      extend Forwardable
      def_instance_delegator :source_handler, :local_path
      # Delegate to class methods
      def_instance_delegators :'self.class', :source, :extracted_source,
                              :hiera, :lookup, :apply

      extend SingleForwardable
      def_single_delegator :hiera, :lookup
    end

    class RubyGemRecipe < BaseRecipe
      def input(config)
        FPM::Cookery::Package::Gem.new(self, config)
      end
    end

    class NPMRecipe < BaseRecipe
      def input(config)
        FPM::Cookery::Package::NPM.new(self, config)
      end
    end

    class PythonRecipe < BaseRecipe
      def input(config)
        FPM::Cookery::Package::Python.new(self, config)
      end
    end

    class CPANRecipe < BaseRecipe
      def input(config)
        FPM::Cookery::Package::CPAN.new(self, config)
      end
    end

    class PEARRecipe < BaseRecipe
      attr_rw :pear_package_name_prefix, :pear_channel, :pear_php_dir

      def input(config)
        FPM::Cookery::Package::PEAR.new(self, config)
      end
    end

    class VirtualenvRecipe < BaseRecipe
      attr_rw :virtualenv_pypi, :virtualenv_install_location, :virtualenv_fix_name,
              :virtualenv_pypi_extra_index_urls, :virtualenv_package_name_prefix,
              :virtualenv_other_files_dir
      def input(config)
        FPM::Cookery::Package::Virtualenv.new(self, config)
      end
    end

    # Helps packaging a directory of content
    class DirRecipe < Recipe

      def input(config)
        FPM::Cookery::Package::Dir.new(self, config)
      end

      # Dir Recipes by default build action.
      def build
      end

      # Default action for a dir recipe install is to copy items selected
      def install
        FileUtils.cp_r File.join(builddir, '.'), destdir
        # Remove build cookies
        %w(build extract).each do |cookie|
          Dir.glob("#{destdir}/.#{cookie}-cookie-*").each do |f|
            Log.info "Deleting FPM Cookie #{f}"
            File.delete(f)
          end
        end
      end
    end
  end
end
