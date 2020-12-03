require_relative '../test_helper.rb'

describe Mushy::Run do

  describe "start" do

    let(:event)    { Object.new }
    let(:step)     { Object.new }
    let(:workflow) { Mushy::Workflow.new }

    let(:uuid) { SecureRandom.uuid }

    before do
      u = uuid
      workflow.id = SecureRandom.uuid

      SecureRandom.expects(:uuid).returns uuid
    end

    it "should return a run" do
      run = Mushy::Run.start event, step, workflow

      run.is_a?(Mushy::Run).must_equal true
    end

    it "should set a run id" do
      run = Mushy::Run.start event, step, workflow
      run.id.must_equal uuid
    end

    it "should set the workflow id on the run" do
      run = Mushy::Run.start event, step, workflow
      run.workflow_id.must_equal workflow.id
    end

  end

end