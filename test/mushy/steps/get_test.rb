require_relative '../../test_helper.rb'

describe Mushy::Get do

  let(:step) { Mushy::Get.new }

  let(:event) { {} }

  let(:config) { {} }

  it "should should make a GET call" do
    config[:url] = 'https://www.google.com'

    result = step.process event, config

    puts result.inspect
  end

end