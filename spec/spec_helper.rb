require 'minitest/autorun'
require 'minitest/pride'

# For my rspec poisoned brain. ;)
module Kernel
  alias_method :context, :describe
end
