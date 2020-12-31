require_relative '../../test_helper.rb'

describe Mushy::EventFormatter do

  let(:step) { Mushy::EventFormatter.new }

  let(:event) { {} }

  it "should return the event it was given" do
    result = step.execute event
    result.must_be_same_as event
  end

end