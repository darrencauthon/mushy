require_relative '../../test_helper.rb'

describe Mushy::EventFormatter do

  let(:step) { Mushy::EventFormatter.new }

  let(:event) { Mushy::Event.new }

  it "should return a hash" do
    result = step.execute event
    result.is_a?(Hash).must_equal true
  end

end