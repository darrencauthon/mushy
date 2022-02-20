require_relative '../../test_helper'

describe Mushy::RegexMatches do
  let(:flux) { Mushy::RegexMatches.new }

  let(:event) { {} }

  let(:config) { { matches: {} } }

  let(:result) { flux.process event, config }

  describe 'no content' do
    it 'should return the event it was given' do
      config[:value] = nil
      config[:regex] = '(\w+)'

      _(result.count).must_equal 0
    end
  end

  describe 'unnamed parameters' do
    describe 'a simple regex match' do
      it 'should return the value' do
        config[:value] = 'apple orange banana'
        config[:regex] = '(\w+)'

        _(result.count).must_equal 3
        _(result[0][:match1]).must_equal 'apple'
        _(result[1][:match1]).must_equal 'orange'
        _(result[2][:match1]).must_equal 'banana'
      end
    end

    describe 'a multiple matches' do
      it 'should return the value' do
        config[:value] = 'apple 1 orange 3 banana 9'
        config[:regex] = '(\w+) (\d+)'

        _(result.count).must_equal 3
        _(result[0][:match1]).must_equal 'apple'
        _(result[0][:match2]).must_equal '1'

        _(result[1][:match1]).must_equal 'orange'
        _(result[1][:match2]).must_equal '3'

        _(result[2][:match1]).must_equal 'banana'
        _(result[2][:match2]).must_equal '9'
      end
    end
  end
end
