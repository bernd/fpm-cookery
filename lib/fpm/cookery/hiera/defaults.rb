module FPM
  module Cookery
    module Hiera
      module Defaults
        module_function

        def hiera_logger
          "fpm_cookery"
        end

        def hiera_hierarchy
          [ENV['FPM_ENV'], "%{platform}", "common"].compact
        end

        def hiera_backends
          [:yaml, :json]
        end

        def hiera_config(options = {})
          {
            :logger     => hiera_logger,
            :hierarchy  => hiera_hierarchy,
            :yaml       => { :datadir  => File.join(Dir.getwd, 'config') },
            :json       => { :datadir  => File.join(Dir.getwd, 'config') },
            :backends   => hiera_backends
          }.merge options[:config] || {}
        end
      end
    end
  end
end

