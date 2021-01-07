
require_relative '../../test_helper.rb'

describe Mushy::Filter do

  let(:step) { Mushy::Filter.new }

  let(:event) { {} }

  let(:config) { {} }

  before do
    step.config[:select] = {}
  end

  describe "equals" do

    it "should return the object if the clause matches" do

      key, value = SecureRandom.uuid, SecureRandom.uuid

      step.config[:select][key] = value

      event[key] = value

      result = step.execute event

      result[key].must_equal value
    end

  end

end