require 'fpm/cookery/exceptions'
require 'fpm/cookery/log'

module FPM
  module Cookery
    module Package
      # See the following URLs for package naming conventions.
      #
      # * https://www.debian.org/doc/debian-policy/ch-controlfields.html#s-f-Version
      # * https://fedoraproject.org/wiki/Packaging:NamingGuidelines?rd=Packaging/NamingGuidelines#Package_Versioning
      class Version
        REVISION_DELIMITER = {
          :default => '-'
        }

        VENDOR_DELIMITER = {
          :deb     => '+',
          :rpm     => '.',
          :default => '-'
        }

        # fpm sets the default version in FPM::Command; since we bypass the
        # command line interface, we need to set our own value.
        DEFAULT_VERSION = '1.0'

        attr_reader :epoch, :revision

        def initialize(recipe, target, config)
          @recipe = recipe
          @target = target
          @config = config
          @revision = recipe.revision
          @version, @epoch = split_version(@recipe.version)

          if !@epoch.nil? and !recipe.epoch.nil?
            # If the epoch is defined in the version string and set in the
            # epoch field, we don't know what to choose.
            message = "The \"epoch\" is defined in the recipe's version (#{@recipe.version}) AND epoch (#{@recipe.epoch}) fields"
            Log.error message
            raise Error::Misconfiguration, message
          end

          # The epoch in the version string has precedence over the #epoch
          # attribute in the recipe. (backward compatibility)
          @epoch = recipe.epoch if @epoch.nil?

          # Ensure that epoch is always a string
          @epoch = @epoch.to_s unless @epoch.nil?
        end

        def vendor
          @config[:vendor] || @recipe.vendor
        end

        def version
          @version ||= DEFAULT_VERSION
        end

        def revision_delimiter
          REVISION_DELIMITER[:default]
        end

        def vendor_delimiter
          return @config[:vendor_delimiter] if @config[:vendor_delimiter]
          VENDOR_DELIMITER[@target.to_sym] || VENDOR_DELIMITER[:default]
        end

        def to_s
          s_revision = revision ? "#{revision_delimiter}#{revision}" : ""
          s_vendor = vendor ? "#{vendor_delimiter}#{vendor}" : ""

          "#{version}#{s_revision}#{s_vendor}"
        end
        alias_method :to_str, :to_s

        private

        def split_version(version)
          (version || '').split(':', 2).reject(&:empty?).reverse
        end
      end
    end
  end
end
