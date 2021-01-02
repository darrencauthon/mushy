require_relative '../../test_helper.rb'

describe Mushy::Split do

  let(:step) { Mushy::Split.new }

  let(:event) { {} }

  let(:config) { {} }

  it "should convert one property with many records into many events" do

    config[:path] = 'hey'

    event[:hey] = [ { a: 'b' }, { c: 'd' } ]

    result = step.process event, config

    puts result.inspect

  end

end