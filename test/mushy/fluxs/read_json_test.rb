require_relative '../../test_helper.rb'

describe Mushy::ReadJson do

  let(:flux) { Mushy::ReadJson.new }

  let(:event) { {} }

  let(:config) { { } }

  it "should convert the string data to a series of events" do

    another_key, another_value = SecureRandom.uuid, SecureRandom.uuid

    data = { another_key => another_value }

    config[:json] = data.to_json

    result = flux.process event, config

    result[another_key].must_equal another_value

  end

end