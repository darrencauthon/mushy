require_relative '../test_helper.rb'

describe Mushy::Step do

  describe "execute" do

    let(:event) { Mushy::Event.new }

    let(:step) { Mushy::Step.new }

    it "should exist" do
      step.execute event
    end

  end

end

describe Mushy::Runner do

  describe "run_event" do

    let(:runner)   { Mushy::Runner.new }
    let(:workflow) { Mushy::Workflow.new }

    let(:event) do
      e = Mushy::Event.new
      e.workflow_id = Object.new
      e
    end

    before do
      Mushy::Workflow.stubs(:find).with(event.workflow_id).returns workflow
    end

    it "should look up all of the steps applicable to the event" do

      steps = [Mushy::Step.new, Mushy::Step.new]

      workflow.stubs(:steps_applicable_to).returns steps

      runner.expects(:run_event_and_step).with(event, steps[0])
      runner.expects(:run_event_and_step).with(event, steps[1])

      runner.run_event event
    end

  end

  describe "run_event_and_step" do

    let(:step)   { Object.new }
    let(:event)  { Mushy::Event.new }

    let(:runner) { Mushy::Runner.new }

    before do
    end

    it "should return the events returned by the step" do
      events = [Mushy::Event.new, Mushy::Event.new]
      step.stubs(:execute).with(event).returns events

      results = runner.run_event_and_step event, step

      results.count.must_equal events.count
      results.each { |r| events.select { |e| e.object_id == r.object_id }.count.must_equal 1 }
    end

    it "should build new events when the step returns hashes" do
      key     = SecureRandom.uuid
      value_1 = SecureRandom.uuid
      value_2 = SecureRandom.uuid

      events = [ { key => value_1 }, { key => value_2 } ]
      step.stubs(:execute).with(event).returns events

      results = runner.run_event_and_step event, step

      results.count.must_equal events.count
      results.each { |r| events.select { |e| e[key] == r.data[key] }.count.must_equal 1 }
    end

    it "should build ignore nil events" do
      key     = SecureRandom.uuid
      value_1 = SecureRandom.uuid
      value_2 = SecureRandom.uuid

      events = [ { key => value_1 }, { key => value_2 }, nil ]
      step.stubs(:execute).with(event).returns events

      results = runner.run_event_and_step event, step

      results.count.must_equal 2
      results.select { |r| r.nil? }.count.must_equal 0
    end

    it "should build new events when the step returns one hash" do
      key     = SecureRandom.uuid
      value_1 = SecureRandom.uuid

      events = { key => value_1 }
      step.stubs(:execute).with(event).returns events

      results = runner.run_event_and_step event, step

      results.count.must_equal 1
      results[0].data[key].must_equal value_1
    end

    it "should carry the run id through" do
      event.run_id = Object.new

      step.stubs(:execute).with(event).returns( {} )

      results = runner.run_event_and_step event, step

      results[0].run_id.must_be_same_as event.run_id
    end

    it "should carry the workflow id through" do
      event.workflow_id = Object.new

      step.stubs(:execute).with(event).returns( {} )

      results = runner.run_event_and_step event, step

      results[0].workflow_id.must_be_same_as event.workflow_id
    end

  end

  describe "start" do

    let(:event_data) { Object.new }

    let(:event)    { Object.new }
    let(:step)     { Object.new }

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

    let(:runner) { Mushy::Runner.new }

    let(:events) { [] }

    before do
      runner.stubs :run_event

      runner.stubs(:find_run).with(step, workflow).returns the_run
      runner.stubs(:build_event).with(event_data, workflow.id, the_run.id).returns event

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
        runner.expects(:run_event).with(child_event_1)
        runner.expects(:run_event).with(child_event_2)
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
      event = runner.build_event event_data, workflow.id, the_run.id
      event.id.must_be_same_as event_id
    end

    it "should return a run" do
      event = runner.build_event event_data, workflow.id, the_run.id
      event.is_a?(Mushy::Event).must_equal true
    end

    it "should set the workflow id" do
      event = runner.build_event event_data, workflow.id, the_run.id
      event.workflow_id.must_equal workflow.id
    end

    it "should set the run id" do
      event = runner.build_event event_data, workflow.id, the_run.id
      event.run_id.must_equal the_run.id
    end

    it "should set the data" do
      event = runner.build_event event_data, workflow.id, the_run.id
      event.data.must_be_same_as event_data
    end

  end

end