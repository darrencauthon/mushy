require 'csv'

module Mushy
  
  class ReadJson < Flux

    def self.details
      {
        name: 'ReadJson',
        title: 'Deserialize JSON',
        fluxGroup: { name: 'JSON' },
        description: 'Read JSON and output it as an event.',
        config: {
          key: {
                 description: 'The JSON contents that will be returned as an event.',
                 type:        'text',
                 value:       'json',
               },
        },
        examples: {
          "Example" => {
                         description: 'Using this Flux to deserialize a JSON string.',
                         input: {
                                  orange: "{\"people\":[{\"name\":\"John\"},{\"name\":\"Jane\"}]}"
                                },
                         config: {
                                   key: 'orange'
                                 },
                         result: { people: [ { name: "John" }, { name: "Jane" } ] }
                       },
                  }
      }
    end

    def process event, config
      return nil unless event[config[:key]].to_s != ''
      JSON.parse event[config[:key]]
    end

  end

end