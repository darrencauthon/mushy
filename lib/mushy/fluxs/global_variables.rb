module Mushy
  
  class GlobalVariables < Flux

    attr_accessor :state

    def self.details
      {
        name: 'GlobalVariables',
        title: 'Global Variables',
        fluxGroup: { name: 'General' },
        description: 'Add global variables to use in any future flux. Returns what was passed to it.',
        config: {
          values: {
                    description: 'Provide key/value pairs that will be set as global variables.',
                    label:       'Variables',
                    type:        'keyvalue',
                    value:       {},
                  },
        },
        examples: {
          "Setting Config Variables" => {
                         description: 'Set a variable to use in any flux. Here, I can use {{api_key}} anywhere.',
                         input: {
                                  hey: 'you'
                                },
                         config: {
                                   values: { api_key: 'my api key' }
                                 },
                         result: {
                                   hey: 'you',
                                 }
                       },
        }
      }
    end

    def initialize
      super
      self.state = SymbolizedHash.new
    end

    def adjust_data data
      state.merge data
    end

    def process event, config
      values = config[:values] || SymbolizedHash.new
      state.merge! values
      event
    end

  end

end