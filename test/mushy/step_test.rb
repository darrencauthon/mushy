require_relative '../test_helper.rb'

class MushyStepTestClass < Mushy::Step

  attr_accessor :return_this

  def process event, config
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

    describe "splitting the results" do

      it "should convert one property with many records into many events" do
        step.config[:split] = 'hey'

        event[:hey] = [ { a: 'b' }, { c: 'd' } ]

        result = step.execute event

        result.count.must_equal 2
        result[0][:a].must_equal 'b'
        result[1][:c].must_equal 'd'
      end

      it "should allow splitting when multiple events are returned" do
        step.config[:split] = 'you'

        events = [
          { you: [ { a: 'b' }, { c: 'd' } ] },
          { you: [ { e: 'f' }, { g: 'h' } ] },
        ]

        result = step.execute events

        result.count.must_equal 4
        result[0][:a].must_equal 'b'
        result[1][:c].must_equal 'd'
        result[2][:e].must_equal 'f'
        result[3][:g].must_equal 'h'
      end

    end

    describe "joining the results" do

      it "should join multiple results from an agent into a single" do
        step.config[:join] = 'hey'

        events = [ { a: 'b' }, { c: 'd' } ]

        # Normally, execute will never get multiple events.
        # I am doing this to quickly replicate multiple events being returned.
        result = step.execute events

        result.count.must_equal 1
        result[:hey][0][:a].must_equal 'b'
        result[:hey][1][:c].must_equal 'd'
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

    describe "merging the results" do

      let(:step) { MushyStepTestClass.new }

      it "should join multiple results from an agent into a single" do

        step.config[:merge] = '*'

        step.return_this = {}

        event[:a] = 'b'

        result = step.execute event

        result[:a].must_equal 'b'

      end

      it "should only merge what is asked" do
        step.config[:merge] = 'c'

        step.return_this = {}

        event[:a] = 'b'
        event[:c] = 'd'

        result = step.execute event

        result[:a].must_be_nil
        result[:c].must_equal 'd'
      end

    end

  end

end