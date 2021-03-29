module Mushy
  
  class GlobalVariables < Flux

    attr_accessor :state

    def self.details
      {
        name: 'GlobalVariables',
        description: 'Add global variables.',
        config: {
          values: {
                    description: 'Provide key/value pairs that will be set as global variables.',
                    label:       'Variables',
                    type:        'keyvalue',
                    value:       {},
                  },
        },
      }
    end

    def initialize
      super
      self.state = SymbolizedHash.new
    end

    def adjust_data data, _
      state.merge data
    end

    def process event, config
      values = config[:values] || SymbolizedHash.new
      state.merge! values
      event
    end

  end

end