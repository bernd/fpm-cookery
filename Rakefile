require 'rake/testtask'
require 'bundler/gem_tasks'

Rake::TestTask.new do |t|
  t.pattern = "spec/*_spec.rb"
  t.libs << 'spec'
  t.verbose = false
end

task :default => :test
