require_relative '../../test_helper.rb'

describe Mushy::Get do

  let(:flux) { Mushy::Get.new }

  let(:event) { {} }

  let(:config) { {} }

  #it "should make a GET call" do
    #config[:url] = 'https://www.google.com'

    #result = flux.process event, config

  #end

  #it "should allow for the controlling of the form with the model" do

    #flux.config[:model] = { reason_phrase: '{{reason_phrase}}' }
    #flux.config[:url] = 'https://www.google.com'

    #result = flux.execute event

  #end

end