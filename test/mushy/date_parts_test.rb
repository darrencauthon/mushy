require_relative '../test_helper.rb'

describe Mushy::DateParts do

  describe "getting values" do

    it "should return a hash" do
      result = Mushy::DateParts.parse Time.now

      result.class.must_equal Hash
    end

    it "should return seconds ago" do
      result = Mushy::DateParts.parse (Time.now - 10)

      result[:seconds_ago].round.must_equal 10
    end

  end

end