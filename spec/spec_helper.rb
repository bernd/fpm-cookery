require 'minitest/autorun'
require 'minitest/pride'

def fixture_path(file)
  File.expand_path("../fixtures/#{file}", __FILE__)
end

# For my rspec poisoned brain. ;)
module Kernel
  alias_method :context, :describe
end
