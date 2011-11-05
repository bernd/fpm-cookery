require 'fpm/cookery/source_handler/template'

module FPM
  module Cookery
    class SourceHandler
      class Git < FPM::Cookery::SourceHandler::Template
        CHECKSUM = false
        NAME = :git

        def fetch
          if local_path.exist?
            Dir.chdir(local_path) do
              git('fetch', url)
            end
          else
            Dir.chdir(cachedir) do
              git('clone', url, local_path)
            end
          end

          local_path
        end

        def extract
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

            # Trailing '/' is important! (see git-checkout-index(1))
            git('checkout-index', '-a', '-f', "--prefix=#{extracted_source}/")
          end

          extracted_source
        end

        private
        def git(command, *args)
          #puts "[DEBUG] git #{command} #{args.join(' ')}"
          safesystem('git', command, *args)
        end
      end
    end
  end
end
