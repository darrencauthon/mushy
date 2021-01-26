require_relative '../../test_helper.rb'

describe Mushy::WriteFile do

  let(:flux) { Mushy::WriteFile.new }

  let(:event) { {} }

  let(:config) { {} }

  it "should write a file" do

    #config[:directory] = 'data'
    config[:name] = 'the_output.txt'
    config[:path] = 'contents'

    event[:contents] = "testing"

    result = flux.process event, config

    result.nil?.must_equal false

  end

end