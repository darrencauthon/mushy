
require_relative '../../test_helper.rb'

describe Mushy::Filter do

  let(:step) { Mushy::Filter.new }

  let(:event) { {} }

  let(:config) { {} }

  describe "matching without config" do

    it "should let the event through when there is no config" do
      key, value = SecureRandom.uuid, SecureRandom.uuid
      event[key] = value

      result = step.execute event
      result[key].must_equal value
    end

    it "should not let strings serve as config" do
      step.config[:equal] = ""
      step.config[:notequal] = ""

      key, value = SecureRandom.uuid, SecureRandom.uuid
      event[key] = value

      result = step.execute event
      result[key].must_equal value
    end

  end

  describe "matching with values" do

    before do
      step.config[:equal] = {}
      step.config[:notequal] = {}
    end

    describe "equal" do

      it "should return the object if the clause matches" do

        key, value = SecureRandom.uuid, SecureRandom.uuid

        step.config[:equal][key] = value

        event[key] = value

        result = step.execute event

        result[key].must_equal value

      end

      it "should NOT return the event if it does not match" do

        key = SecureRandom.uuid

        step.config[:equal][key] = SecureRandom.uuid

        event[key] = SecureRandom.uuid

        result = step.execute event

        result.count.must_equal 0

      end

      it "should match numbers and numeric strings in a loosey-goosey way" do
        step.config[:equal][:number] = "01"
        event[:number] = "001"

        result = step.execute event
        result[:number].must_equal "001"
      end

      it "another loosey-goosey number match" do
        step.config[:equal][:number] = "1"
        event[:number] = 1

        result = step.execute event
        result[:number].must_equal 1
      end

      it "should trim the strings before matching" do
        step.config[:equal][:number] = "  a   "
        event[:number] = "a"

        result = step.execute event
        result[:number].must_equal "a"
      end

      it "should be case-insensitive" do
        step.config[:equal][:number] = "A"
        event[:number] = "a"
  
        result = step.execute event
        result[:number].must_equal "a"
      end

    end

    describe "not equal" do

      it "should NOT return the value if it matches" do

        key, value = SecureRandom.uuid, SecureRandom.uuid

        step.config[:notequal][key] = value

        event[key] = value

        result = step.execute event

        result.count.must_equal 0

      end

      it "should return the event if the clause does not match" do

        key, value = SecureRandom.uuid, SecureRandom.uuid

        step.config[:notequal][key] = SecureRandom.uuid

        event[key] = value

        result = step.execute event

        result[key].must_equal value

      end

    end

  end

end