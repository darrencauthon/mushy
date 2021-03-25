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

      it "should return an empty hash for an empty hash" do
        result = masher.mash({}, {})
        result.any?.must_equal false
      end

      it "should return a hash with the same value" do
        value = SecureRandom.uuid
        masher.mash( { name: "{{ name }}" }, { "name" => value } )[:name].must_equal value
      end

      it "should handle hashes with hashes" do
        value = SecureRandom.uuid
        masher.mash( { test: { name: "{{ name }}" } }, { "name" => value } )[:test][:name].must_equal value
      end

      it "should NOT alter the original" do
        value = SecureRandom.uuid
        input = { test: { name: "{{ name }}" } }
        masher.mash(input, { "name" => value } )

        input[:test][:name].must_equal "{{ name }}"
      end

    end

    describe "with an array" do

      it "should return a hash with the same value" do
        value = SecureRandom.uuid
        masher.mash(['{{ name }}'], { "name" => value } )[0].must_equal value
      end

    end

    describe "with more complicated objects than value types" do

      it "should still pass the complicated object through" do
        darren = Object.new
        masher.mash("{{ darren }}", { darren: darren }).must_be_same_as darren
      end

      it "should return nothing if the objet does not match" do
        darren = Object.new
        masher.mash("{{ darren }}", { something_else: darren }).must_equal ''
      end

    end

  end

  describe "dig" do

    it "should pull data out of a simple hash" do
      key, value = SecureRandom.uuid, SecureRandom.uuid
      data = { key => value }

      result = masher.dig key, data
      result.must_equal value
    end

    it "should pull data out of a deeper hash" do
      value = SecureRandom.uuid
      data = { one: { two: value } }

      result = masher.dig 'one.two', data
      result.must_equal value
    end

    it "should allow indexed retrieval" do
      value1 = SecureRandom.uuid
      value2 = SecureRandom.uuid
      data = { one: [ { name: value1 }, { name: value2 } ] }

      result = masher.dig 'one[0].name', data
      result.must_be_same_as value1

      result = masher.dig 'one[1].name', data
      result.must_be_same_as value2
    end

  end

end