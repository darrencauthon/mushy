require_relative '../test_helper.rb'

class MushyStepTestClass < Mushy::Step

  attr_accessor :return_this

  def process event
    return_this
  end

end

describe Mushy::Step do

  let(:step) { Mushy::Step.new }
  let(:event) { Mushy::Event.new }

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

    describe "handling processed results" do

      let(:step) { MushyStepTestClass.new }

      it "should return an empty set when nil is returned" do
        step.return_this = nil
        result = step.execute(event)
        result.empty?.must_equal true
        result.is_a?(Array).must_equal true
      end

      it "should return a single hash when a single hash is returned" do
        step.return_this = {}
        result = step.execute(event)
        result.empty?.must_equal true
        result.is_a?(Hash).must_equal true
      end

      it "should return an array when an array is returned" do
        step.return_this = [{}, {}]
        result = step.execute(event)
        result.empty?.must_equal false
        result.count.must_equal 2
      end

    end

  end

end