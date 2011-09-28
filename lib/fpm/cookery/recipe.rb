require 'fpm/cookery/source/types'
require 'fpm/cookery/utils'
require 'fpm/cookery/path_helper'

module FPM
  module Cookery
    class Recipe
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

      def self.attr_rw_list(*attrs)
        attrs.each do |attr|
          class_eval %Q{
            def self.#{attr}(*list)
              @#{attr} ||= superclass.respond_to?(:#{attr}) ? superclass.#{attr} : []
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
              :revision, :section, :spec, :vendor, :version

      attr_rw_list :build_depends, :config_files, :conflicts, :depends,
                   :exclude, :patches, :provides, :replaces

      class << self
        def source(source_url = nil, options = {})
          return @source if source_url.nil?
          @source = Source::Types.new_type_for(source_url, options)
        end
        alias_method :url, :source
      end

      def source
        self.class.source
      end

      def initialize(filename)
        @filename = Path.new(filename).expand_path

        # Set some defaults.
        vendor || self.class.vendor('fpm')
        revision || self.class.revision(0)
      end

      attr_reader :filename, :source_handler

      def workdir=(value)  @workdir  = Path.new(value) end
      def destdir=(value)  @destdir  = Path.new(value) end
      def builddir=(value) @builddir = Path.new(value) end
      def pkgdir=(value)   @pkgdir   = Path.new(value) end
      def cachedir=(value) @cachedir = Path.new(value) end

      def workdir(path = nil)  (@workdir  ||= filename.dirname)/path       end
      def destdir(path = nil)  (@destdir  ||= workdir('tmp-dest'))/path    end
      def builddir(path = nil) (@builddir ||= workdir('tmp-build'))/path   end
      def pkgdir(path = nil)   (@pkgdir   ||= workdir('pkg'))/path         end
      def cachedir(path = nil) (@cachedir ||= workdir('cache'))/path       end
    end
  end
end
