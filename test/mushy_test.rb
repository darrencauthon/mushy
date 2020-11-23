require_relative 'test_helper.rb'

class MushyTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Mushy::VERSION
  end
end