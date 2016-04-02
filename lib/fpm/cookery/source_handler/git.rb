require 'fpm/cookery/source_handler/template'
require 'fpm/cookery/log'

module FPM
  module Cookery
    class SourceHandler
      class Git < FPM::Cookery::SourceHandler::Template
        CHECKSUM = false
        NAME = :git

        def fetch(config = {})
          rev = options[:sha] || options[:tag]

          if local_path.exist?
            Dir.chdir(local_path) do
              if rev and has_rev?(rev)
                Log.info("Skipping fetch, rev #{rev} exists.")
              else
                git('fetch', url)
                git('fetch', '--tags', url)
              end
            end
          else
            Dir.chdir(cachedir) do
              git('clone', url, local_path)
            end
          end

          local_path
        end

        def extract(config = {})
          extracted_source = (builddir/local_path.basename('.git').to_s).to_s

          Dir.chdir(local_path) do
            if options[:sha]
              git('reset', '--hard', options[:sha])
              extracted_source << "-#{options[:sha]}"
            elsif options[:tag]
              git('checkout', '-f', options[:tag])
              extracted_source << "-tag-#{options[:tag]}"
            elsif options[:branch]
              git('checkout', '-f', "origin/#{options[:branch]}")
              extracted_source << "-branch-#{options[:branch]}"
            else
              git('checkout', '-f', 'origin/HEAD')
              extracted_source << '-HEAD'
            end

            # Initialize submodules after sha/tag/branch has been set.
            # See: https://github.com/bernd/fpm-cookery/issues/144
            git('submodule', 'update', '--init') if options[:submodule]

            case options.fetch(:extract, :default).to_s.to_sym
            when :clone
              if File.exist?(extracted_source)
                Log.info("Source directory has already been cloned into #{extracted_source}")
              else
                git('clone', '-l', '--recurse-submodules', Dir.pwd, extracted_source)
              end
            else
              # Trailing '/' is important! (see git-checkout-index(1))
              git('checkout-index', '-a', '-f', "--prefix=#{extracted_source}/")

              if options[:submodule]
                git('submodule', 'foreach', "mkdir -p #{extracted_source}/$path && cp -r . #{extracted_source}/$path")
              end
            end
          end

          extracted_source
        end

        private
        def git(command, *args)
          Log.debug "git #{command} #{args.join(' ')}"
          safesystem('git', command, *args)
        end

        def has_rev?(rev)
          Log.debug "git show #{rev} >/dev/null 2>&1"
          safesystem("git show #{rev} >/dev/null 2>&1")
          true
        rescue
          false
        end
      end
    end
  end
end
