require_relative '../test_helper.rb'

describe Mushy::Step do

  let(:step) { Mushy::Step.new }

  describe "the basics" do

    it "should have a config block" do
      step.config.is_a?(SymbolizedHash).must_equal true
    end

    it "should have parent steps" do
      step.parent_steps.count.must_equal 0
    end

    it "should have a unique id" do
      step.id.nil?.must_equal false
    end

  end

end