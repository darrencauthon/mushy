module Mushy
  
  class EventFormatter < Step

    attr_accessor :masher

    def initialize
      super
      self.masher = Masher.new
    end

    def process event
      instructions = config[:instructions] || {}
      masher.mash instructions, event.data
    end

  end

end