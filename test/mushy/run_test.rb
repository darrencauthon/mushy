require_relative '../test_helper.rb'

describe Mushy::Runner do

  describe "a more concrete example" do

    let(:runner)   { Mushy::Runner.new }
    let(:flow) { Mushy::Flow.new }

    it "should work with one flux" do
      starting_flux = Mushy::Flux.new
      starting_flux.id = 'small flux'
      flow.fluxs = [starting_flux]
      runner.start({}, starting_flux, flow)
    end

    it "should work with two fluxs" do
      starting_flux = Mushy::Flux.new
      starting_flux.id = 'first flux'

      second_flux = Mushy::Flux.new
      second_flux.parent_flux << starting_flux
      second_flux.id = 'second flux'

      flow.fluxs = [starting_flux, second_flux]

      runner.start({}, starting_flux, flow)
    end

    it "should work with two children" do
      starting_flux = Mushy::Flux.new

      first_child = Mushy::Flux.new
      first_child.parent_fluxs << starting_flux
      first_child.id = 'first child'

      second_child = Mushy::Flux.new
      second_child.parent_fluxs << starting_flux
      second_child.id = 'second child'

      flow.fluxs = [starting_flux, first_child, second_child]

      runner.start({}, starting_flux, flow)
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

      flow.fluxs = [a, b, c]

      runner.start({}, a, flow)
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

      flow.fluxs = [a, b, c, d]

      runner.start({}, a, flow)
    end

  end

end