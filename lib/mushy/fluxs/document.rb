module Mushy
  
  class Document < Flux

    def self.details
      {
        name: 'Document',
        title: 'Make a multi-line liquid value',
        description: 'Create a multi-line document.',
        fluxGroup: { name: 'Flows' },
        config: {
          document: {
                      description: 'The multi-line document you wish to create.',
                      type:        'textarea',
                      value:       '',
                    },
        },
        examples: {
          "Example" => {
                         description: 'Using this Flux to build a document',
                         input: {
                                  people: [ { name: "John" }, { name: "Jane" } ]
                                },
                         config: {
                                   document: '{% for person in people %} {{ person.name }} {% endfor %}'
                                 },
                         result: {
                                   document: ' John  Jane ',
                                 }
                       },
          }
      }
    end

    def process event, config
      {
        document: config[:document],
      }
    end

  end

end