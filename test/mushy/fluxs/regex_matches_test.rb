require_relative '../../test_helper'

describe Mushy::RegexMatches do
  let(:flux) { Mushy::RegexMatches.new }

  let(:event) { {} }

  let(:config) { {} }

  let(:result) { flux.process event, config }

  describe 'there are no regex matches' do
    it 'should return the event it was given' do
      config[:value] = 'apple orange banana'
      config[:regex] = '(\w+)'

      _(result.count).must_equal 3
      _(result[0][:match]).must_equal 'apple'
      _(result[1][:match]).must_equal 'orange'
      _(result[2][:match]).must_equal 'banana'
    end
  end
end
