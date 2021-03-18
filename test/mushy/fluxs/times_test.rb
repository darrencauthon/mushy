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

  it "should return an index on each" do
    config[:times] = 4
    result = flux.process event, config
    result[0][:index].must_equal 0
    result[1][:index].must_equal 1
    result[2][:index].must_equal 2
    result[3][:index].must_equal 3
  end

  it "should work with string times" do
    config[:times] = '4'
    result = flux.process event, config
    result.count.must_equal 4
  end

end