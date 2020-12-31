module Mushy
  
  class EventFormatter < Step

    attr_accessor :masher

    def initialize
      super
      self.masher = Masher.new
    end

    def process event
      data = {}
      (config[:instructions] || {}).each do |key, value|
        data[key] = Masher.new.mash value, event.data
      end
      data
    end

  end

end