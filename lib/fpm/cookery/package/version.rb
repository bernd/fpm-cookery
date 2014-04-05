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

        attr_reader :version, :epoch, :revision

        def initialize(recipe, target, config)
          @recipe = recipe
          @target = target
          @config = config
          @revision = recipe.revision
          @version, @epoch = split_version(@recipe.version)
        end

        def vendor
          @config[:vendor] || @recipe.vendor
        end

        def revision_delimiter
          REVISION_DELIMITER[:default]
        end

        def vendor_delimiter
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
          epoch, version = version.split(':', 2)

          version.nil? ? [epoch, nil] : [version, epoch]
        end
      end
    end
  end
end
