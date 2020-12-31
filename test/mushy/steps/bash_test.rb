require_relative '../../test_helper.rb'

describe Mushy::Bash do

  let(:step) { Mushy::Bash.new }

  let(:event) { {} }

  let(:config) { {} }

  it "should return the event it was given" do
    config[:command] = 'ls'

    result = step.process event, config

    puts result.inspect
  end

end