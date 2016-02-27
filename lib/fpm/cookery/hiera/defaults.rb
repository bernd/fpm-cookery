module FPM
  module Cookery
    module Hiera
      module Defaults
        module_function

        # This will result in Hiera using the +Hiera::Fpm_cookery_logger+ class
        # for logging.
        def hiera_logger
          'fpm_cookery'
        end

        # Sets the default search hierarchy.  +Hiera+ will look for files
        # matching +"#{ENV['FPM_ENV']}.yaml"+, etc.
        # Note: the including class is expected to define a +recipe+ method
        # that responds to +platform+ and +target+.
        def hiera_hierarchy
          ['common']
        end

        # Default to attempting lookups using both +.yaml+ and +.json+ files.
        def hiera_backends
          [:yaml, :json]
        end

        def hiera_datadir
          File.join(Dir.getwd, 'config')
        end

        # Sets default values for the +{:config => { ... }}+ options hash
        # passed to the +Hiera+ constructor, merging in any options from the
        # caller.
        def hiera_config(options = {})
          # Hiera accepts a path to a configuration file or a hash; short
          # circuit if it's the former.
          return options[:config] unless options[:config].is_a?(Hash)

          {
            :logger     => hiera_logger,
            :hierarchy  => hiera_hierarchy,
            :yaml       => { :datadir  => hiera_datadir },
            :json       => { :datadir  => hiera_datadir },
            :backends   => hiera_backends
          }.merge options[:config] || {}
        end
      end
    end
  end
end

