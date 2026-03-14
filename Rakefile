require 'rspec/core/rake_task'
require 'bundler/gem_tasks'

desc 'Run all specs'
RSpec::Core::RakeTask.new(:spec)

task :default => :spec

namespace 'test:ruby' do |ns|
  src = File.dirname(File.expand_path(__FILE__))

  %w(3.4 3.3 3.2 3.1 3.0 2.7).each do |version|
    task version do
      sh %(
        docker run -i --rm -v #{src}:/src ruby:#{version}
        bash -c '
        git config --global --add safe.directory /src/.git
        && git clone -s /src /work
        && cd /work
        && bundle install -j 4
        && bundle exec rake
        '
      ).gsub(/\s+/, ' ').strip
    end
  end
end

namespace 'test:distro' do
  src = File.dirname(File.expand_path(__FILE__))

  distros = {
    'debian-11'     => 'debian:11',
    'debian-12'     => 'debian:12',
    'debian-13'     => 'debian:trixie',
    'ubuntu-20.04'  => 'ubuntu:20.04',
    'ubuntu-22.04'  => 'ubuntu:22.04',
    'ubuntu-24.04'  => 'ubuntu:24.04',
    'rocky-8'       => 'rockylinux:8',
    'rocky-9'       => 'rockylinux:9',
    'alpine-3.18'   => 'alpine:3.18',
    'alpine-3.19'   => 'alpine:3.19',
    'alpine-3.20'   => 'alpine:3.20',
    'fedora-40'     => 'fedora:40',
    'fedora-41'     => 'fedora:41',
  }

  distros.each do |name, image|
    install_cmd = case image
    when /debian|ubuntu/
      'apt-get update && apt-get install -y ruby ruby-dev build-essential git'
    when /rockylinux:8/
      # Rocky 8 ships with Ruby 2.5, enable Ruby 3.1 module stream
      'dnf module enable -y ruby:3.1 && dnf install -y ruby ruby-devel gcc gcc-c++ make git redhat-rpm-config'
    when /rockylinux|fedora/
      'dnf install -y ruby ruby-devel gcc gcc-c++ make git redhat-rpm-config'
    when /alpine/
      'apk add ruby ruby-dev build-base git'
    end

    # Install bundler with version check for Ruby < 3.0
    bundler_install = 'ruby -e "puts RUBY_VERSION" | grep -q "^2\\." && gem install bundler -v 2.4.22 || gem install bundler'

    desc "Run tests on #{name}"
    task name do
      sh %(docker run -i --rm -v #{src}:/src #{image} sh -c '
        #{install_cmd} &&
        #{bundler_install} &&
        git config --global --add safe.directory /src &&
        cp -r /src /work && cd /work &&
        bundle install -j 4 &&
        COVERAGE=false bundle exec rspec spec/facts_spec.rb spec/dependency_inspector_spec.rb spec/integration/native_detection_spec.rb
      ').gsub(/\s+/, ' ').strip
    end
  end

  desc 'Run tests on all distributions'
  task :all => distros.keys
end

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
