module Mushy
  
  class StartWorkflow < Flux

    def self.details
      {
        name: 'StartWorkflow',
        description: 'Start another workflow.',
        config: {
          file: {
                  description: 'Workflow to start.',
                  type:        'text',
                  value:       '{{file}}',
                },
        },
      }
    end

    def process event, config
      nil
    end

  end

end