require_relative '../test_helper.rb'

describe Mushy::Masher do

  let(:masher) { Mushy::Masher.new }

  describe "mash" do

    describe "with a string" do

      it "should return what we give it" do
        value = SecureRandom.uuid
        masher.mash(value, {} ).must_equal value
      end

      it "should use basic liquid templating" do
        value = SecureRandom.uuid
        masher.mash("{{ name }}", { "name" => value } ).must_equal value
      end

      it "should allow for symbolized hashes" do
        value = SecureRandom.uuid
        masher.mash("{{ name }}", { name: value } ).must_equal value
      end

    end

    describe "with a hash" do

      it "should return a hash with the same value" do
        value = SecureRandom.uuid
        masher.mash( { name: "{{ name }}" }, { "name" => value } )[:name].must_equal value
      end

      it "should handle hashes with hashes" do
        value = SecureRandom.uuid
        masher.mash( { test: { name: "{{ name }}" } }, { "name" => value } )[:test][:name].must_equal value
      end

    end

  end

end