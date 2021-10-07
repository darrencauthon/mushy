require_relative '../../test_helper.rb'

describe Mushy::ReadCsv do

  let(:flux) { Mushy::ReadCsv.new }

  let(:event) { {} }

  let(:config) { {} }

  it "should convert the string data to a series of events" do
    config[:data] = %{a,b,c
d,e,f}

    result = flux.process event, config

    result.count.must_equal 2
    result[0]['a'].must_equal 'a'
    result[0]['b'].must_equal 'b'
    result[0]['c'].must_equal 'c'
    result[1]['a'].must_equal 'd'
    result[1]['b'].must_equal 'e'
    result[1]['c'].must_equal 'f'
  end

  it "should allow headers" do
    config[:headers] = true

    config[:data] = %{a,b,c
d,e,f}

    result = flux.process event, config

    result.count.must_equal 1
    result[0]['a'].must_equal 'd'
    result[0]['b'].must_equal 'e'
    result[0]['c'].must_equal 'f'
  end

  it "should allow a model to convert header-less data to something better" do
    flux.config[:model] = {
      first: '{{a}}',
      second: '{{b}}',
      third: '{{c}}',
    }

    flux.config[:data] = %{a,b,c
d,e,f}

    result = flux.execute event

    puts result.inspect
  end

end