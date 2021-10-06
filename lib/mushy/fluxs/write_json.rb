require 'csv'

module Mushy
  
  class WriteJson < Flux

    def self.details
      {
        name: 'WriteJson',
        title: "Serialize as JSON",
        description: 'Write the incoming event as JSON.',
        config: {
          key: {
                description: 'The key of the outgoing field that will contain the JSON.',
                type:        'text',
                value:       'json',
              },
        },
        examples: {
          "Example" => {
                         description: 'Using this Flux to convert input to a JSON string.',
                         input: {
                                  people: [ { name: "John" }, { name: "Jane" } ]
                                },
                         config: {
                                   key: 'apple'
                                 },
                         result: {
                                   apple: "{\"people\":[{\"name\":\"John\"},{\"name\":\"Jane\"}]}"
                                 }
                       },
          }
      }
    end

    def process event, config
      {
        config[:key] => event.to_json
      }
    end

  end

end