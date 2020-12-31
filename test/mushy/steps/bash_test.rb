require_relative '../../test_helper.rb'

describe Mushy::Bash do

  let(:step) { Mushy::Bash.new }

  let(:event) { {} }

  it "should return the event it was given" do
    event[:leaf] = 'ls'
    step.config[:command] = '{{leaf}}'

    result = step.execute event

    puts result.inspect
  end

end