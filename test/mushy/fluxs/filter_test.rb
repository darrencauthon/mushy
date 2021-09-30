
require_relative '../../test_helper.rb'

describe Mushy::Filter do

  let(:flux) { Mushy::Filter.new }

  let(:event) { {} }

  let(:config) { {} }

  describe "matching without config" do

    it "should let the event through when there is no config" do
      key, value = SecureRandom.uuid, SecureRandom.uuid
      event[key] = value

      result = flux.execute event
      result[key].must_equal value
    end

    it "should not let strings serve as config" do
      flux.config[:equal] = ""
      flux.config[:notequal] = ""

      key, value = SecureRandom.uuid, SecureRandom.uuid
      event[key] = value

      result = flux.execute event
      result[key].must_equal value
    end

  end

  describe "matching with values" do

    before do
      flux.config[:equal] = {}
      flux.config[:notequal] = {}
      flux.config[:contains] = {}
    end

    describe "equal" do

      it "should return the object if the clause matches" do

        key, value = SecureRandom.uuid, SecureRandom.uuid

        flux.config[:equal][key] = value

        event[key] = value

        result = flux.execute event

        result[key].must_equal value

      end

      it "should NOT return the event if it does not match" do

        key = SecureRandom.uuid

        flux.config[:equal][key] = SecureRandom.uuid

        event[key] = SecureRandom.uuid

        result = flux.execute event

        result.count.must_equal 0

      end

      it "should match numbers and numeric strings in a loosey-goosey way" do
        flux.config[:equal][:number] = "01"
        event[:number] = "001"

        result = flux.execute event
        result[:number].must_equal "001"
      end

      it "another loosey-goosey number match" do
        flux.config[:equal][:number] = "1"
        event[:number] = 1

        result = flux.execute event
        result[:number].must_equal 1
      end

      it "should trim the strings before matching" do
        flux.config[:equal][:number] = "  a   "
        event[:number] = "a"

        result = flux.execute event
        result[:number].must_equal "a"
      end

      it "should be case-insensitive" do
        flux.config[:equal][:number] = "A"
        event[:number] = "a"
  
        result = flux.execute event
        result[:number].must_equal "a"
      end

    end

    describe "not equal" do

      it "should NOT return the value if it matches" do

        key, value = SecureRandom.uuid, SecureRandom.uuid

        flux.config[:notequal][key] = value

        event[key] = value

        result = flux.execute event

        result.count.must_equal 0

      end

      it "should return the event if the clause does not match" do

        key, value = SecureRandom.uuid, SecureRandom.uuid

        flux.config[:notequal][key] = SecureRandom.uuid

        event[key] = value

        result = flux.execute event

        result[key].must_equal value

      end

    end

    describe "contains" do

      it "should return the value if the string is contained" do

        key, value = SecureRandom.uuid, SecureRandom.uuid

        flux.config[:contains][key] = value

        value_containing_our_target = "#{SecureRandom.uuid}#{value}#{SecureRandom.uuid}"
        event[key] = value_containing_our_target

        result = flux.execute event

        result[key].must_equal value_containing_our_target

      end

    end

  end

end