require_relative '../../test_helper.rb'

describe Mushy::EventFormatter do

  let(:step) { Mushy::EventFormatter.new }

  let(:event) { Mushy::Event.new }

  it "should return a hash" do
    result = step.execute event
    result.is_a?(Hash).must_equal true
  end

  describe "setting config" do

    before do
      step.config[:instructions] = SymbolizedHash.new
    end

    it "should allow hardcoded results" do
      key = SecureRandom.uuid
      value = SecureRandom.uuid

      step.config[:instructions][key] = value

      result = step.execute(event)

      result[key].must_equal value
    end

    it "should should allow mashing" do
      key = SecureRandom.uuid
      value = SecureRandom.uuid

      step.config[:instructions]['test mashing'] = "{{#{key}}}"

      event.data[key] = value

      result = step.execute(event)

      result['test mashing'].must_equal value
    end

  end

end