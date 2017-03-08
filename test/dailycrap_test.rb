require 'test_helper'

class DailycrapTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Dailycrap::VERSION
  end
end
