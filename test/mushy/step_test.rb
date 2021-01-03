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

      it "should allow conditional merging with a comma-delimited string" do
        step.config[:merge] = 'c, e'

        step.return_this = {}

        event[:a] = 'b'
        event[:c] = 'd'
        event[:e] = 'f'

        result = step.execute event

        result[:a].must_be_nil
        result[:c].must_equal 'd'
        result[:e].must_equal 'f'
      end

      it "should allow conditional merging with an array" do
        step.config[:merge] = ['c', 'e']

        step.return_this = {}

        event[:a] = 'b'
        event[:c] = 'd'
        event[:e] = 'f'

        result = step.execute event

        result[:a].must_be_nil
        result[:c].must_equal 'd'
        result[:e].must_equal 'f'
      end

      it "should always give precedence to the data returned from the step" do

        step.config[:merge] = '*'

        step.return_this = { a: 'c' }

        event[:a] = 'b'

        result = step.execute event

        result[:a].must_equal 'c'

      end

    end

    describe "shaping the results" do

      let(:step) { MushyStepTestClass.new }

      describe "swapping join and merge" do

        before do
          step.config[:join] = 'records'
          step.config[:merge] = '*'

          event[:original] = 'yes'

          step.return_this = [ { a: 1 }, { a: 2 } ]
        end

        describe "joining before merging" do

          it "should allow me to join before merging" do
            step.config[:shaping] = [:join, :merge]

            result = step.execute event

            result[:records].count.must_equal 2
            result[:original].must_equal 'yes'
            result[:records][0][:original].must_be_nil
            result[:records][1][:original].must_be_nil
          end

          it "should allow the shaping to be an array of strings" do
            step.config[:shaping] = ['join', 'merge']

            result = step.execute event

            result[:records].count.must_equal 2
            result[:original].must_equal 'yes'
            result[:records][0][:original].must_be_nil
            result[:records][1][:original].must_be_nil
          end

          it "should allow the shaping to be a comma-delimited list of strings" do
            step.config[:shaping] = 'join,merge'

            result = step.execute event

            result[:records].count.must_equal 2
            result[:original].must_equal 'yes'
            result[:records][0][:original].must_be_nil
            result[:records][1][:original].must_be_nil
          end

        end

        it "should allow me to merge before joining" do
          step.config[:shaping] = [:merge, :join]

          result = step.execute event

          result[:records].count.must_equal 2
          result[:original].must_be_nil
          result[:records][0][:original].must_equal 'yes'
          result[:records][1][:original].must_equal 'yes'
        end

      end

    end

    describe "sorting the results" do
      let(:step) { MushyStepTestClass.new }

      before do
      end

      it "should only sort numeric values" do
        step.config[:sort] = 'a'

        step.return_this = [1, 2, 3, 4, 5]
                             .map { |x| { a: x } }
                             .reverse

        result = step.execute event

        result.count.must_equal 5
        result[0][:a].must_equal 1
        result[1][:a].must_equal 2
        result[2][:a].must_equal 3
        result[3][:a].must_equal 4
        result[4][:a].must_equal 5
      end

      it "should sort string values that are numeric" do
        step.config[:sort] = 'a'

        step.return_this = [1, 2, 3, 4, 5]
                             .map { |x| { a: x.to_s } }
                             .reverse

        result = step.execute event

        result.count.must_equal 5
        result[0][:a].must_equal '1'
        result[1][:a].must_equal '2'
        result[2][:a].must_equal '3'
        result[3][:a].must_equal '4'
        result[4][:a].must_equal '5'
      end

      it "should sort string values that are NOT numeric" do
        step.config[:sort] = 'a'

        step.return_this = ['xe', 'xd', 'xc', 'xb', 'xa']
                             .map { |x| { a: x.to_s } }
                             .reverse

        result = step.execute event

        result.count.must_equal 5
        result[0][:a].must_equal 'xa'
        result[1][:a].must_equal 'xb'
        result[2][:a].must_equal 'xc'
        result[3][:a].must_equal 'xd'
        result[4][:a].must_equal 'xe'
      end
    end

    describe "limiting the results" do

      let(:step) { MushyStepTestClass.new }

      before do
        step.return_this = [1, 2, 3, 4, 5].map { |x| { a: x } }
      end

      it "should only return the number of results expected" do
        step.config[:limit] = 2

        result = step.execute event

        result.count.must_equal 2
      end

      it "should allow the limit to be a string" do
        step.config[:limit] = '2'

        result = step.execute event

        result.count.must_equal 2
      end

    end

  end

end