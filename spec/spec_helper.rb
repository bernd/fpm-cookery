unless RUBY_ENGINE == "rbx" || ENV['COVERAGE'] == 'false'
  require "simplecov"

  formatters = [SimpleCov::Formatter::HTMLFormatter]
  SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter.new(formatters)
  SimpleCov.start do
    minimum_coverage 75
    add_group "Sources", "lib"
    add_group "Tests", "spec"
  end
end

RSpec.configure do |config|
  config.run_all_when_everything_filtered = true
  config.filter_run :focus

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = 'random'

  config.raise_errors_for_deprecations!
end

require_relative "support/shared_context"

def fixture_path(file)
  File.expand_path("../fixtures/#{file}", __FILE__)
end
