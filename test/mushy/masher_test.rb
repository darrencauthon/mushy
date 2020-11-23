require_relative '../test_helper.rb'

describe Mushy::Masher do

  let(:masher) { Mushy::Masher.new }

  describe "mash" do

    it "should return what we give it" do
      value = SecureRandom.uuid
      masher.mash(value, {} ).must_equal value
    end

  end

end