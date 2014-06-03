require 'forwardable'
require 'fileutils'
require 'fpm/cookery/facts'
require 'fpm/cookery/source'
require 'fpm/cookery/source_handler'
require 'fpm/cookery/utils'
require 'fpm/cookery/path_helper'
require 'fpm/cookery/package/cpan'
require 'fpm/cookery/package/dir'
require 'fpm/cookery/package/gem'
require 'fpm/cookery/package/npm'
require 'fpm/cookery/package/pear'
require 'fpm/cookery/package/python'

module FPM
  module Cookery
    class BaseRecipe
      include FileUtils
      include FPM::Cookery::Utils
      include FPM::Cookery::PathHelper

      def self.attr_rw(*attrs)
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

      def self.inherited(klass)
        super
        # Apply class data inheritable pattern to @fpm_attributes
        # class variable.
        klass.instance_variable_set(:@fpm_attributes, self.fpm_attributes.dup)
      end

      def self.platforms(valid_platforms)
        Array(valid_platforms).member?(self.platform) and block_given? ? yield : false
      end

      def self.architectures(archs)
        Array(archs).member?(FPM::Cookery::Facts.arch) and block_given? ? yield : false
      end

      def self.attr_rw_list(*attrs)
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

      attr_rw :arch, :description, :homepage, :maintainer, :md5, :name,
              :revision, :section, :sha1, :sha256, :spec, :vendor, :version,
              :pre_install, :post_install, :pre_uninstall, :post_uninstall,
              :license, :omnibus_package, :omnibus_dir, :chain_package

      attr_rw_list :build_depends, :config_files, :conflicts, :depends,
                   :exclude, :patches, :provides, :replaces, :omnibus_recipes,
                   :omnibus_additional_paths, :chain_recipes, :directories

      attr_reader :filename

      class << self
        def platform
          FPM::Cookery::Facts.platform
        end

        def depends_all
          (depends + build_depends).uniq
        end

        # Supports both hash and argument assignment
        #   fpm_attributes[:attr1] = xxxx
        #   fpm_attributes :xxxx=>1, :yyyy=>2
        def fpm_attributes(args=nil)
          if args.is_a?(Hash)
            @fpm_attributes.merge!(args)
          end
          @fpm_attributes
        end
      end
      @fpm_attributes = {}

      def initialize(filename, config)
        @filename = Path.new(filename).expand_path
        @config = config

        @workdir = @filename.dirname
        @tmp_root = @config.tmp_root ? Path.new(@config.tmp_root) : @workdir
        @pkgdir = @config.pkg_dir && Path.new(@config.pkg_dir)
        @cachedir = @config.cache_dir && Path.new(@config.cache_dir)
      end

      def workdir=(value)  @workdir  = Path.new(value) end
      def tmp_root=(value) @tmp_root = Path.new(value) end
      def destdir=(value)  @destdir  = Path.new(value) end
      def builddir=(value) @builddir = Path.new(value) end
      def pkgdir=(value)   @pkgdir   = Path.new(value) end
      def cachedir=(value) @cachedir = Path.new(value) end

      def workdir(path = nil)  @workdir/path                               end
      def tmp_root(path = nil) @tmp_root/path                              end
      def destdir(path = nil)  (@destdir  || tmp_root('tmp-dest'))/path    end
      def builddir(path = nil) (@builddir || tmp_root('tmp-build'))/path   end
      def pkgdir(path = nil)   (@pkgdir   || workdir('pkg'))/path         end
      def cachedir(path = nil) (@cachedir || workdir('cache'))/path       end
      def fpm_attributes() self.class.fpm_attributes end

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
    end

    class Recipe < BaseRecipe
      def input(config)
        FPM::Cookery::Package::Dir.new(self, config)
      end

      def initialize(filename, config)
        super(filename, config)
        @source_handler = SourceHandler.new(Source.new(source, spec), cachedir, builddir)
      end

      class << self
        def source(source = nil, spec = {})
          return @source if source.nil?
          @source = source
          @spec = spec
        end
        alias_method :url, :source
      end

      def source
        self.class.source
      end

      attr_reader :source_handler

      extend Forwardable
      def_delegator :@source_handler, :local_path
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
  end
end
