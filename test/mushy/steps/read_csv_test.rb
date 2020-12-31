require_relative '../../test_helper.rb'

describe Mushy::ReadCsv do

  let(:step) { Mushy::ReadCsv.new }

  let(:event) { {} }

  let(:config) { {} }

  it "should convert the string data to a series of events" do
    key = SecureRandom.uuid

    config[:key] = key

    event[key] = %{a,b,c
d,e,f}

    result = step.process event, config

    puts result.inspect
  end

  it "should allow headers" do
    key = SecureRandom.uuid

    config[:key] = key
    config[:headers] = true

    event[key] = %{a,b,c
d,e,f}

    result = step.process event, config

    puts result.inspect
  end

  it "should allow a model to convert header-less data to something better" do
    key = SecureRandom.uuid

    step.config[:key] = key

    step.config[:model] = {
      first: '{{a}}',
      second: '{{b}}',
      third: '{{c}}',
    }

    event[key] = %{a,b,c
d,e,f}

    result = step.execute event

    puts result.inspect
  end

end