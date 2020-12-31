module Mushy
  
  class EventFormatter < Step

    def process event
      data = {}
      (config[:instructions] || {}).each do |key, value|
        data[key] = Masher.new.mash value, event.data
      end
      data
    end

  end

end