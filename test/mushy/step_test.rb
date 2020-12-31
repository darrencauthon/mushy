require_relative '../test_helper.rb'

class MushyStepTestClass < Mushy::Step

  attr_accessor :return_this

  def process event
    return_this
  end

end

describe Mushy::Step do

  let(:step) { Mushy::Step.new }
  let(:event) { {} }

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

    describe "standardizing the results" do

      let(:step) { MushyStepTestClass.new }

      it "should return a single hash when a single hash is returned" do
        value = SecureRandom.uuid
        step.return_this = { "key" => value }

        result = step.execute(event)

        result["key"].must_equal value
        result[:key].must_equal value
      end

    end

    describe "setting config" do

      let(:step) { MushyStepTestClass.new }

      before do
        step.config[:model] = SymbolizedHash.new

        step.return_this = event
      end

      it "should allow hardcoded results" do
        key = SecureRandom.uuid
        value = SecureRandom.uuid

        step.config[:model][key] = value

        result = step.execute(event)

        result[key].must_equal value
      end

      it "should should allow mashing" do
        key = SecureRandom.uuid
        value = SecureRandom.uuid

        step.config[:model]['test mashing'] = "{{#{key}}}"

        event[key] = value

        result = step.execute(event)

        result['test mashing'].must_equal value
      end

    end

  end

end