require_relative '../test_helper.rb'

describe Mushy::Runner do

  describe "start" do

    let(:event_data) { Object.new }

    let(:event)    { Object.new }
    let(:step)     { Object.new }
    let(:workflow) { Object.new }
    let(:the_run)  { Object.new }

    let(:runner) { Mushy::Runner.new }

    let(:events) { [] }

    before do
      Mushy::EventRunner.stubs :run

      runner.stubs(:find_run).with(step, workflow).returns the_run
      runner.stubs(:build_event).with(event_data, workflow, the_run).returns event

      step.stubs(:execute).with(event).returns events
    end

    it "should return a run" do
      run = runner.start event_data, step, workflow

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
        runner.start event_data, step, workflow
      end
    end

  end

  describe "finding a run" do

    let(:step)     { Mushy::Step.new }
    let(:workflow) { Mushy::Workflow.new }

    let(:runner) { Mushy::Runner.new }

    it "should return a run" do
      run = runner.find_run step, workflow
      run.is_a?(Mushy::Run).must_equal true
    end

    it "should set the workflow id" do
      workflow.id = SecureRandom.uuid
      run = runner.find_run step, workflow
      run.workflow_id.must_equal workflow.id
    end

    it "should set the run id to a new uuid" do
      run_id = SecureRandom.uuid
      SecureRandom.stubs(:uuid).returns run_id
      run = runner.find_run step, workflow
      run.id.must_equal run_id
    end

  end

  describe "building an event" do

    let(:event_data) { Object.new }

    let(:runner) { Mushy::Runner.new }

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
      event = runner.build_event event_data, workflow, the_run
      event.id.must_be_same_as event_id
    end

    it "should return a run" do
      event = runner.build_event event_data, workflow, the_run
      event.is_a?(Mushy::Event).must_equal true
    end

    it "should set the workflow id" do
      event = runner.build_event event_data, workflow, the_run
      event.workflow_id.must_equal workflow.id
    end

    it "should set the run id" do
      event = runner.build_event event_data, workflow, the_run
      event.run_id.must_equal the_run.id
    end

    it "should set the data" do
      event = runner.build_event event_data, workflow, the_run
      event.data.must_be_same_as event_data
    end

  end

end