require_relative '../test_helper.rb'

describe Mushy::Runner do

  describe "a more concrete example" do

    let(:runner)   { Mushy::Runner.new }
    let(:workflow) { Mushy::Workflow.new }

    it "should work with one flux" do
      starting_flux = Mushy::Flux.new
      starting_flux.id = 'small flux'
      workflow.fluxs = [starting_flux]
      runner.start({}, starting_flux, workflow)
    end

    it "should work with two fluxs" do
      starting_flux = Mushy::Flux.new
      starting_flux.id = 'first flux'

      second_flux = Mushy::Flux.new
      second_flux.parent_flux << starting_flux
      second_flux.id = 'second flux'

      workflow.fluxs = [starting_flux, second_flux]

      runner.start({}, starting_flux, workflow)
    end

    it "should work with two children" do
      starting_flux = Mushy::Flux.new

      first_child = Mushy::Flux.new
      first_child.parent_fluxs << starting_flux
      first_child.id = 'first child'

      second_child = Mushy::Flux.new
      second_child.parent_fluxs << starting_flux
      second_child.id = 'second child'

      workflow.fluxs = [starting_flux, first_child, second_child]

      runner.start({}, starting_flux, workflow)
    end

    it "should allow a chain from A to B to C" do
      a = Mushy::Flux.new
      a.id = 'A'

      b = Mushy::Flux.new
      b.parent_fluxs << a
      b.id = 'B'

      c = Mushy::Flux.new
      c.parent_fluxs << b
      c.id = 'C'

      workflow.fluxs = [a, b, c]

      runner.start({}, a, workflow)
    end

    it "should allow a chain from A to B to C to D" do
      a = Mushy::Flux.new
      a.id = 'A'

      b = Mushy::Flux.new
      b.parent_fluxs << a
      b.id = 'B'

      c = Mushy::Flux.new
      c.parent_fluxs << b
      c.id = 'C'

      d = Mushy::Flux.new
      d.parent_fluxs << c
      d.id = 'D'

      workflow.fluxs = [a, b, c, d]

      runner.start({}, a, workflow)
    end

  end

end