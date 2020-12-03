require_relative '../test_helper.rb'

describe Mushy::Run do

  describe "start" do

    it "should return a run" do
      event    = Object.new
      step     = Object.new
      workflow = Object.new

      run = Mushy::Run.start event, step, workflow

      run.is_a?(Mushy::Run).must_equal true
    end

  end

end