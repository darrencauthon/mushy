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

  it "should not alter the original config" do
    step.config[:command] = '{{leaf}}'

    event[:leaf] = 'clear'

    result = step.execute event

    event[:leaf] = 'ls'

    result = step.execute event

    puts result.inspect
  end

end