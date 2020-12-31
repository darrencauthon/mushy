require_relative '../../test_helper.rb'

describe Mushy::Get do

  let(:step) { Mushy::Get.new }

  let(:event) { {} }

  let(:config) { {} }

  it "should make a GET call" do
    config[:url] = 'https://www.google.com'

    result = step.process event, config

    #puts result.inspect
  end

  it "should allow for the controlling of the form with the model" do

    step.config[:model] = { reason_phrase: '{{reason_phrase}}' }
    step.config[:url] = 'https://www.google.com'

    result = step.execute event

    puts result.inspect
  end

end