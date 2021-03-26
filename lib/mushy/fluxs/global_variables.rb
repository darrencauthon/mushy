module Mushy
  
  class GlobalVariables < Flux

    def self.details
      {
        name: 'GlobalVariables',
        description: 'Add global variables.',
        config: {
        },
      }
    end

    def initialize
      state = SymbolizedHash.new
    end

    def adjust_data data
      puts 'ADJUSTING DATA'
      puts data.inspect
      data
    end

    def process event, config
      event
    end

  end

end