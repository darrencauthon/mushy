require_relative '../test_helper.rb'

describe Mushy::Run do

  describe "start" do

    let(:event)    { Object.new }
    let(:step)     { Mushy::Step.new }
    let(:workflow) { Mushy::Workflow.new }

    let(:events) { [] }

    let(:uuid) { SecureRandom.uuid }

    before do
      u = uuid
      workflow.id = SecureRandom.uuid

      SecureRandom.stubs(:uuid).returns uuid

      Mushy::StepRunner.stubs(:run)

      step.stubs(:execute).with(event).returns events
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

    describe "when there are child events" do

      let (:child_event) { Mushy::Event.new }

      before do
        events << child_event
      end

      it "should load them up" do
        Mushy::StepRunner.expects(:run).with(child_event)
        Mushy::Run.start event, step, workflow
      end
    end

  end

end