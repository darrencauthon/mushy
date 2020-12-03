require_relative '../test_helper.rb'

describe Mushy::Run do

  describe "start" do

    let(:event)    { Object.new }
    let(:step)     { Object.new }
    let(:workflow) { Object.new }

    let(:uuid) { SecureRandom.uuid }

    before do
      u = uuid
      SecureRandom.expects(:uuid).returns uuid
    end

    it "should return a run" do
      run = Mushy::Run.start event, step, workflow

      run.is_a?(Mushy::Run).must_equal true

      run.id.must_equal uuid
    end

  end

end