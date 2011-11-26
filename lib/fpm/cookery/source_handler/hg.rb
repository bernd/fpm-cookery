require 'fpm/cookery/source_handler/template'
require 'fpm/cookery/log'

module FPM
  module Cookery
    class SourceHandler
      class Hg < FPM::Cookery::SourceHandler::Template
        CHECKSUM = false
        NAME = :hg

        def fetch
          if local_path.exist?
            Dir.chdir(local_path) do
              hg('pull')
              hg('update')
            end
          else
            Dir.chdir(cachedir) do
              hg('clone', url, local_path)
            end
          end

          local_path
        end

        def extract
          src = (builddir/local_path.basename('.hg').to_s).to_s

          Dir.chdir(local_path) do
            if options[:rev]
              src << "-#{options[:rev]}"
              hg('archive', '-y', '-r', options[:rev], '-t', 'files', src)
            else
              src << '-tip'
              hg('archive', '-y', '-t', 'files', src)
            end
          end

          src
        end

        private
        def hg(command, *args)
          Log.debug "hg #{command} #{args.join(' ')}"
          safesystem('hg', command, *args)
        end
      end
    end
  end
end
