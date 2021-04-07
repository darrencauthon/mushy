require_relative '../../test_helper.rb'

describe Mushy::WriteJson do

  let(:flux) { Mushy::WriteJson.new }

  let(:event) { {} }

  let(:config) { { key: the_key } }

  let(:the_key) { SecureRandom.uuid }

  it "should convert the string data to a series of events" do

    another_key, another_value = SecureRandom.uuid, SecureRandom.uuid

    event[another_key] = another_value

    result = flux.process event, config

    result[the_key].must_equal event.to_json

  end

end