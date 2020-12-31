module Mushy

  class Step

    attr_accessor :id
    attr_accessor :parent_steps

    def initialize
      self.id = SecureRandom.uuid
      self.parent_steps = []
    end

    def execute event
      puts id
    end

  end

  class ThroughStep < Step
    def execute event
      puts "id: #{id}"
      puts event.inspect
      event
    end
  end

end