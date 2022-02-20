module Mushy

  class Format < Flux

    def self.details
      {
        name: 'Format',
        title: 'Alter the format of an event',
        description: 'Return the event passed to it. This opens the opportunity to use the common fluxing to alter the event.',
        fluxGroup: { name: 'Flows' },
        config: {},
        examples: {
          "Simplest Example" => {
                                  description: 'It only returns what is passed to it.',
                                  input: {
                                           hello: 'world',
                                         },
                                  config: {
                                          },
                                  result: {
                                            hello: 'world',
                                          }
                                },
          "Changing The Event" => {
                                    description: 'The common fluxing can still be used to alter the event.',
                                    input: {
                                             things: [
                                                       { name: "Elephant", type: "Mammal" },
                                                       { name: "Alligator", type: "Reptile" },
                                                       { name: "Giraffe", type: "Mammal" }
                                                     ]
                                           },
                                    config: { outgoing_split:"things",group:"type|animal_type" },
                                    result: [
                                              {
                                                animal_type: [
                                                              {
                                                                name: "Elephant",
                                                                type: "Mammal"
                                                              },
                                                              {
                                                                name: "Giraffe",
                                                                type: "Mammal"
                                                              }
                                                            ]
                                              },
                                              { animal_type:[ { name:"Alligator",type:"Reptile" } ] }
                                            ]
                                },
        }
      }
    end

    def process event, config
      event
    end

  end

end
