
require_relative '../../test_helper.rb'

describe Mushy::Filter do

  let(:step) { Mushy::Filter.new }

  let(:event) { {} }

  let(:config) { {} }

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