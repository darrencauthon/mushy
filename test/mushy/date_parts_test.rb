require_relative '../test_helper.rb'

describe Mushy::DateParts do

  describe "getting values" do

    it "should return a hash" do
      result = Mushy::DateParts.parse Time.now

      result.class.must_equal Hash
    end

  end

end