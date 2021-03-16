require_relative '../test_helper.rb'

class MushyFluxTestClass < Mushy::Flux

  attr_accessor :return_this

  def process event, config
    return_this
  end

end

class MushyFluxTestClassWithLambda < Mushy::Flux

  attr_accessor :do_this

  def process event, config
    do_this.call event, config
  end

end

describe Mushy::Flux do

  let(:flux) { Mushy::Flux.new }
  let(:event) { {} }

  describe "the basics" do

    it "should have a config block" do
      flux.config.is_a?(SymbolizedHash).must_equal true
    end

    it "should have parent fluxs" do
      flux.parent_fluxs.count.must_equal 0
    end

    it "should have an empty subscribed to" do
      flux.subscribed_to.count.must_equal 0
    end

    it "should have a unique id" do
      flux.id.nil?.must_equal false
    end

    describe "handling processed results" do

      let(:flux) { MushyFluxTestClass.new }

      it "should return an empty set when nil is returned" do
        flux.return_this = nil
        result = flux.execute(event)
        result.empty?.must_equal true
        result.is_a?(Array).must_equal true
      end

      it "should return a single hash when a single hash is returned" do
        flux.return_this = {}
        result = flux.execute(event)
        result.empty?.must_equal true
        result.is_a?(Hash).must_equal true
      end

      it "should return an array when an array is returned" do
        flux.return_this = [{}, {}]
        result = flux.execute(event)
        result.empty?.must_equal false
        result.count.must_equal 2
      end

    end

    describe "incoming split" do

      let(:flux) { MushyFluxTestClass.new }

      it "should split, then process each, then merge the results" do

        event[:a] = [ { b: 'c' }, { b: 'd' } ]
        flux.return_this = { z: 'y' }

        flux.config[:incoming_split] = 'a'

        result = flux.execute event

        result.count.must_equal 2
      end

      it "allow a join after the incoming split" do

        event[:a] = [ { b: 'c' }, { b: 'd' } ]
        flux.return_this = { z: 'y' }

        flux.config[:incoming_split] = 'a'
        flux.config[:join] = 'heyyou'

        result = flux.execute event

        result.count.must_equal 1
        result[0]['heyyou'].count.must_equal 2
        result[0]['heyyou'][0][:z].must_equal 'y'
      end

      it "allow a join after the incoming split even when multiple results are returned" do

        event[:a] = [ { b: 'c' }, { b: 'd' } ]
        flux.return_this = [{ z: 'y' }]

        flux.config[:incoming_split] = 'a'
        flux.config[:join] = 'heyyou'

        result = flux.execute event

        result.count.must_equal 1
        result[0]['heyyou'].count.must_equal 2
        result[0]['heyyou'][0][:z].must_equal 'y'
      end

    end

    describe "grouping the results" do

      let(:flux) { MushyFluxTestClass.new }

      it "should group on the provided key" do

        flux.return_this = [ { a: 'b', y: 1 }, { a: 'b', y: 2 }, { a: 'c', y: 3 } ]

        flux.config[:group] = 'a|hey'

        result = flux.execute event

        result.count.must_equal 2
        result[0][:hey].count.must_equal 2
        result[0][:hey][0][:y].must_equal 1
        result[0][:hey][1][:y].must_equal 2
        result[1][:hey].count.must_equal 1
        result[1][:hey][0][:y].must_equal 3
      end

    end

    describe "outgoing split the results" do

      it "should convert one property with many records into many events" do
        flux.config[:outgoing_split] = 'hey'

        event[:hey] = [ { a: 'b' }, { c: 'd' } ]

        result = flux.execute event

        result.count.must_equal 2
        result[0][:a].must_equal 'b'
        result[1][:c].must_equal 'd'
      end

      it "should allow splitting when multiple events are returned" do
        flux.config[:outgoing_split] = 'you'

        events = [
          { you: [ { a: 'b' }, { c: 'd' } ] },
          { you: [ { e: 'f' }, { g: 'h' } ] },
        ]

        result = flux.execute events

        result.count.must_equal 4
        result[0][:a].must_equal 'b'
        result[1][:c].must_equal 'd'
        result[2][:e].must_equal 'f'
        result[3][:g].must_equal 'h'
      end

    end

    describe "joining the results" do

      it "should join multiple results from an agent into a single" do
        flux.config[:join] = 'hey'

        events = [ { a: 'b' }, { c: 'd' } ]

        # Normally, execute will never get multiple events.
        # I am doing this to quickly replicate multiple events being returned.
        result = flux.execute events

        result.count.must_equal 1
        result[:hey][0][:a].must_equal 'b'
        result[:hey][1][:c].must_equal 'd'
      end

    end

    describe "standardizing the results" do

      let(:flux) { MushyFluxTestClass.new }

      it "should return a single hash when a single hash is returned" do
        value = SecureRandom.uuid
        flux.return_this = { "key" => value }

        result = flux.execute(event)

        result["key"].must_equal value
        result[:key].must_equal value
      end

    end

    describe "setting config" do

      let(:flux) { MushyFluxTestClass.new }

      before do
        flux.config[:model] = SymbolizedHash.new

        flux.return_this = event
      end

      it "should allow hardcoded results" do
        key = SecureRandom.uuid
        value = SecureRandom.uuid

        flux.config[:model][key] = value

        result = flux.execute(event)

        result[key].must_equal value
      end

      it "should should allow mashing" do
        key = SecureRandom.uuid
        value = SecureRandom.uuid

        flux.config[:model]['test mashing'] = "{{#{key}}}"

        event[key] = value

        result = flux.execute(event)

        result['test mashing'].must_equal value
      end

    end

    describe "merging the results" do

      let(:flux) { MushyFluxTestClass.new }

      it "should join multiple results from an agent into a single" do

        flux.config[:merge] = '*'

        flux.return_this = {}

        event[:a] = 'b'

        result = flux.execute event

        result[:a].must_equal 'b'

      end

      it "should only merge what is asked" do
        flux.config[:merge] = 'c'

        flux.return_this = {}

        event[:a] = 'b'
        event[:c] = 'd'

        result = flux.execute event

        result[:a].must_be_nil
        result[:c].must_equal 'd'
      end

      it "should allow conditional merging with a comma-delimited string" do
        flux.config[:merge] = 'c, e'

        flux.return_this = {}

        event[:a] = 'b'
        event[:c] = 'd'
        event[:e] = 'f'

        result = flux.execute event

        result[:a].must_be_nil
        result[:c].must_equal 'd'
        result[:e].must_equal 'f'
      end

      it "should allow conditional merging with an array" do
        flux.config[:merge] = ['c', 'e']

        flux.return_this = {}

        event[:a] = 'b'
        event[:c] = 'd'
        event[:e] = 'f'

        result = flux.execute event

        result[:a].must_be_nil
        result[:c].must_equal 'd'
        result[:e].must_equal 'f'
      end

      it "should always give precedence to the data returned from the flux" do

        flux.config[:merge] = '*'

        flux.return_this = { a: 'c' }

        event[:a] = 'b'

        result = flux.execute event

        result[:a].must_equal 'c'

      end

    end

    describe "shaping the results" do

      let(:flux) { MushyFluxTestClass.new }

      describe "swapping join and merge" do

        before do
          flux.config[:join] = 'records'
          flux.config[:merge] = '*'

          event[:original] = 'yes'

          flux.return_this = [ { a: 1 }, { a: 2 } ]
        end

        describe "joining before merging" do

          it "should allow me to join before merging" do
            flux.config[:shaping] = [:join, :merge]

            result = flux.execute event

            result[:records].count.must_equal 2
            result[:original].must_equal 'yes'
            result[:records][0][:original].must_be_nil
            result[:records][1][:original].must_be_nil
          end

          it "should allow the shaping to be an array of strings" do
            flux.config[:shaping] = ['join', 'merge']

            result = flux.execute event

            result[:records].count.must_equal 2
            result[:original].must_equal 'yes'
            result[:records][0][:original].must_be_nil
            result[:records][1][:original].must_be_nil
          end

          it "should allow the shaping to be a comma-delimited list of strings" do
            flux.config[:shaping] = 'join,merge'

            result = flux.execute event

            result[:records].count.must_equal 2
            result[:original].must_equal 'yes'
            result[:records][0][:original].must_be_nil
            result[:records][1][:original].must_be_nil
          end

        end

        it "should allow me to merge before joining" do
          flux.config[:shaping] = [:merge, :join]

          result = flux.execute event

          result[:records].count.must_equal 2
          result[:original].must_be_nil
          result[:records][0][:original].must_equal 'yes'
          result[:records][1][:original].must_equal 'yes'
        end

      end

    end

    describe "sorting the results" do
      let(:flux) { MushyFluxTestClass.new }

      before do
      end

      it "should only sort numeric values" do
        flux.config[:sort] = 'a'

        flux.return_this = [1, 2, 3, 4, 5]
                             .map { |x| { a: x } }
                             .reverse

        result = flux.execute event

        result.count.must_equal 5
        result[0][:a].must_equal 1
        result[1][:a].must_equal 2
        result[2][:a].must_equal 3
        result[3][:a].must_equal 4
        result[4][:a].must_equal 5
      end

      it "should sort string values that are numeric" do
        flux.config[:sort] = 'a'

        flux.return_this = [1, 2, 3, 4, 5]
                             .map { |x| { a: x.to_s } }
                             .reverse

        result = flux.execute event

        result.count.must_equal 5
        result[0][:a].must_equal '1'
        result[1][:a].must_equal '2'
        result[2][:a].must_equal '3'
        result[3][:a].must_equal '4'
        result[4][:a].must_equal '5'
      end

      it "should sort string values that are NOT numeric" do
        flux.config[:sort] = 'a'

        flux.return_this = ['xe', 'xd', 'xc', 'xb', 'xa']
                             .map { |x| { a: x.to_s } }
                             .reverse

        result = flux.execute event

        result.count.must_equal 5
        result[0][:a].must_equal 'xa'
        result[1][:a].must_equal 'xb'
        result[2][:a].must_equal 'xc'
        result[3][:a].must_equal 'xd'
        result[4][:a].must_equal 'xe'
      end
    end

    describe "limiting the results" do

      let(:flux) { MushyFluxTestClass.new }

      before do
        flux.return_this = [1, 2, 3, 4, 5].map { |x| { a: x } }
      end

      it "should only return the number of results expected" do
        flux.config[:limit] = 2

        result = flux.execute event

        result.count.must_equal 2
      end

      it "should allow the limit to be a string" do
        flux.config[:limit] = '2'

        result = flux.execute event

        result.count.must_equal 2
      end

    end

    describe "error handling" do
      let(:flux)   { MushyFluxTestClassWithLambda.new }
      let(:config) { SymbolizedHash.new }
      let(:event)  { SymbolizedHash.new }

      before do
        flux.config = config
      end

      describe "no error config" do

        before do
          flux.do_this = ->(x, y) { raise 'this should error' }
        end

        it "should throw the exception by default" do
          exception_thrown = false
          begin
            flux.execute event
          rescue
            exception_thrown = true
          end
          exception_thrown.must_equal true
        end

        it "should throw the same exception" do
          exception = Exception.new 'hello'
          flux.do_this = ->(x, y) { raise exception }
          begin
            flux.execute event
          rescue Exception => ex
            ex.must_be_same_as exception
          end
        end

        it "should throw the exception if the config is an empty string" do
          config[:error_strategy] = ''
          exception_thrown = false
          begin
            flux.execute event
          rescue
            exception_thrown = true
          end
          exception_thrown.must_equal true
        end

      end

      describe "returning an error" do

        before do
          config[:error_strategy] = 'return'
          flux.do_this = ->(x, y) { raise 'this should error' }
        end

        it "should eat the error when returning" do
          exception_thrown = false
          begin
            flux.execute event
          rescue
            exception_thrown = true
          end
          exception_thrown.must_equal false
        end

        it "return a message with the exception detail" do
          result = flux.execute event
          result[:exception].must_equal 'this should error'
        end

      end

      describe "ignoring an error" do

        before do
          config[:error_strategy] = 'ignore'
          flux.do_this = ->(x, y) { raise 'this should error' }
        end

        it "should eat the error when returning" do
          exception_thrown = false
          begin
            flux.execute event
          rescue
            exception_thrown = true
          end
          exception_thrown.must_equal false
        end

        it "should return nil when ignoring" do
          result = flux.execute event
          result.must_be_nil
        end

      end

    end

  end

end