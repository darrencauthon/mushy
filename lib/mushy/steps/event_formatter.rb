module Mushy
  
  class EventFormatter < Step

    attr_accessor :masher

    def initialize
      super
      self.masher = Masher.new
    end

    def process event
      event
    end

  end

end