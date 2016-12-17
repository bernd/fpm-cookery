require 'rspec/core/rake_task'
require 'bundler/gem_tasks'

desc 'Run all specs'
RSpec::Core::RakeTask.new(:spec)

task :default => :spec

namespace :docs do |ns|
  require 'systemu'

  docs_dir = File.join(File.dirname(File.expand_path(__FILE__)), 'docs')

  Dir.chdir docs_dir do
    sphinxbuild = ENV['SPHINXBUILD'] || 'sphinx-build'

    status, stdout, stderr = systemu "make SPHINXBUILD=#{sphinxbuild} help"
    if status != 0 and Rake.verbose
      $stderr.puts '# Unable to load tasks in the `docs` namespace:'
      stderr.each_line { |l| $stderr.puts "# #{l}" }
    end

    desc 'clean up doc builds'
    task 'clean' do
      Dir.chdir docs_dir do
        system "make SPHINXBUILD=#{sphinxbuild} clean"
      end
    end

    stdout.each_line.grep(/^\s+(\w+?)\s+(.*)$/) do
      t, d = $1, $2

      desc d
      task t do
        Dir.chdir docs_dir do
          system "make SPHINXBUILD=#{sphinxbuild} #{t}"
        end
      end
    end
  end
end
