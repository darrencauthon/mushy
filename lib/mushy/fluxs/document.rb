module Mushy
  
  class Document < Flux

    def self.details
      {
        name: 'Document',
        description: 'Create a multi-line document.',
        config: {
          document: {
                      description: 'The multi-line document you wish to create.',
                      type:        'textarea',
                      value:       '',
                    },
        },
      }
    end

    def process event, config
      {
        document: config[:document],
      }
    end

  end

end