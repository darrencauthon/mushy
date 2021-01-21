module Mushy

  class Event
    attr_accessor :id
    attr_accessor :run_id
    attr_accessor :flux_id
    attr_accessor :workflow_id
    attr_accessor :data

    def initialize
      self.data = SymbolizedHash.new
    end
  end

end