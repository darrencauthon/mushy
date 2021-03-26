module Mushy
  
  class GlobalVariables < Flux

    attr_accessor :state

    def self.details
      {
        name: 'GlobalVariables',
        description: 'Add global variables.',
        config: {
        },
      }
    end

    def initialize
      super
      self.state = SymbolizedHash.new
    end

    def adjust_data data
      puts 'ADJUSTING DATA'
      puts data.inspect
      state.merge data
    end

    def process event, config
      state.merge! event
      event
    end

  end

end