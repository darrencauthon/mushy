require_relative '../../test_helper.rb'

describe Mushy::Times do

  let(:flux)   { Mushy::Times.new }
  let(:event)  { SymbolizedHash.new }
  let(:config) { SymbolizedHash.new }

  let(:the_key)   { Object.new }
  let(:the_value) { Object.new }

  before do
    flux.config = config
    event[the_key] = the_value
  end

  it "should return the event it was given" do
    config[:times] = 1
    result = flux.process event, config
    result.count.must_equal 1
  end

  it "should return the event it was given" do
    config[:times] = 3
    result = flux.process event, config
    result.count.must_equal 3
  end

  it "should return the same event" do
    config[:times] = 1
    result = flux.process event, config
    result[0][the_key].must_be_same_as the_value
  end

end