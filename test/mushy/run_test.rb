require_relative '../test_helper.rb'

describe Mushy::Run do

  describe "start" do

    let(:event)    { Object.new }
    let(:step)     { Mushy::Step.new }
    let(:workflow) { Mushy::Workflow.new }

    let(:the_run) { Mushy::Run.new }

    let(:events) { [] }

    before do
      workflow.id = SecureRandom.uuid

      Mushy::EventRunner.stubs :run

      Mushy::Run.stubs(:find_run).with(event, step, workflow).returns the_run

      step.stubs(:execute).with(event).returns events
    end

    it "should return a run" do
      run = Mushy::Run.start event, step, workflow

      run.must_be_same_as the_run
    end

    describe "when there are child events" do

      let (:child_event_1) { Mushy::Event.new }
      let (:child_event_2) { Mushy::Event.new }

      before do
        events << child_event_1
        events << child_event_2
      end

      it "should load them up" do
        Mushy::EventRunner.expects(:run).with(child_event_1)
        Mushy::EventRunner.expects(:run).with(child_event_2)
        Mushy::Run.start event, step, workflow
      end
    end

  end

  describe "finding a run" do

    let(:event)    { Object.new }
    let(:step)     { Mushy::Step.new }
    let(:workflow) { Mushy::Workflow.new }

    it "should return a run" do
      run = Mushy::Run.find_run event, step, workflow
      run.is_a?(Mushy::Run).must_equal true
    end

    it "should set the workflow id" do
      workflow.id = SecureRandom.uuid
      run = Mushy::Run.find_run event, step, workflow
      run.workflow_id.must_equal workflow.id
    end

    it "should set the run id to a new uuid" do
      run_id = SecureRandom.uuid
      SecureRandom.stubs(:uuid).returns run_id
      run = Mushy::Run.find_run event, step, workflow
      run.id.must_equal run_id
    end

  end

end