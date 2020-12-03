require_relative '../test_helper.rb'

describe Mushy::Run do

  describe "start" do

    let(:event_data) { Object.new }

    let(:event) { Mushy::Event.new }
    let(:step)  { Mushy::Step.new }

    let(:workflow) do
      w = Mushy::Workflow.new
      w.id = SecureRandom.uuid
      w
    end

    let(:the_run) do
      r = Mushy::Run.new
      r.id = SecureRandom.uuid
      r
    end

    let(:events) { [] }

    before do
      Mushy::EventRunner.stubs :run

      Mushy::Run.stubs(:find_run).with(step, workflow).returns the_run
      Mushy::Run.stubs(:build_event).with(event_data, step, workflow, the_run).returns event

      step.stubs(:execute).with(event).returns events
    end

    it "should return a run" do
      run = Mushy::Run.start event_data, step, workflow

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
        Mushy::Run.start event_data, step, workflow
      end
    end

  end

  describe "finding a run" do

    let(:step)     { Mushy::Step.new }
    let(:workflow) { Mushy::Workflow.new }

    it "should return a run" do
      run = Mushy::Run.find_run step, workflow
      run.is_a?(Mushy::Run).must_equal true
    end

    it "should set the workflow id" do
      workflow.id = SecureRandom.uuid
      run = Mushy::Run.find_run step, workflow
      run.workflow_id.must_equal workflow.id
    end

    it "should set the run id to a new uuid" do
      run_id = SecureRandom.uuid
      SecureRandom.stubs(:uuid).returns run_id
      run = Mushy::Run.find_run step, workflow
      run.id.must_equal run_id
    end

  end

  describe "building an event" do

    let(:event_data) { Object.new }
    let(:step)       { Mushy::Step.new }

    let(:workflow) do
      w = Mushy::Workflow.new
      w.id = SecureRandom.uuid
      w
    end

    let(:the_run) do
      r = Mushy::Run.new
      r.id = SecureRandom.uuid
      r
    end

    it "should set the id to a random guid" do
      event_id = Object.new
      SecureRandom.stubs(:uuid).returns event_id
      event = Mushy::Run.build_event event_data, step, workflow, the_run
      event.id.must_be_same_as event_id
    end

    it "should return a run" do
      event = Mushy::Run.build_event event_data, step, workflow, the_run
      event.is_a?(Mushy::Event).must_equal true
    end

    it "should set the workflow id" do
      event = Mushy::Run.build_event event_data, step, workflow, the_run
      event.workflow_id.must_equal workflow.id
    end

    it "should set the run id" do
      event = Mushy::Run.build_event event_data, step, workflow, the_run
      event.run_id.must_equal the_run.id
    end

  end

end