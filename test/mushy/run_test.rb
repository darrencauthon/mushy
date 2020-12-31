require_relative '../test_helper.rb'

describe Mushy::Runner do

  describe "a more concrete example" do

    let(:runner)   { Mushy::Runner.new }
    let(:workflow) { Mushy::Workflow.new }

    it "should work with one step" do
      starting_step = Mushy::ThroughStep.new
      starting_step.id = 'small step'
      workflow.steps = [starting_step]
      runner.start({}, starting_step, workflow)
    end

    it "should work with two steps" do
      starting_step = Mushy::ThroughStep.new
      starting_step.id = 'first step'

      second_step = Mushy::ThroughStep.new
      second_step.parent_steps << starting_step
      second_step.id = 'second step'

      workflow.steps = [starting_step, second_step]

      runner.start({}, starting_step, workflow)
    end

    it "should work with two children" do
      starting_step = Mushy::ThroughStep.new

      first_child = Mushy::ThroughStep.new
      first_child.parent_steps << starting_step
      first_child.id = 'first child'

      second_child = Mushy::ThroughStep.new
      second_child.parent_steps << starting_step
      second_child.id = 'second child'

      workflow.steps = [starting_step, first_child, second_child]

      runner.start({}, starting_step, workflow)
    end

    it "should allow a chain from A to B to C" do
      a = Mushy::ThroughStep.new
      a.id = 'A'

      b = Mushy::ThroughStep.new
      b.parent_steps << a
      b.id = 'B'

      c = Mushy::ThroughStep.new
      c.parent_steps << b
      c.id = 'C'

      workflow.steps = [a, b, c]

      runner.start({}, a, workflow)
    end

  end

end