module Mushy
  
  class Filter < Flux

    def self.details
      {
        name: 'Filter',
        description: 'Filters events based on criteria.',
        config: {
          equal: {
                 description: 'Provide key/value pairs that must match in the event.',
                 shrink:      true,
                 label:       'Equal To',
                 type:        'keyvalue',
                 value:       {},
               },
          notequal: {
                 description: 'Provide key/value pairs that must NOT match in the event.',
                 shrink:      true,
                 label:       'Not Equal To',
                 type:        'keyvalue',
                 value:       {},
               },
          contains: {
                 description: 'Provide key/value pairs that must be contained.',
                 shrink:      true,
                 label:       'Contains',
                 type:        'keyvalue',
                 value:       {},
               },
          notcontains: {
                 description: 'Provide key/value pairs that must NOT be contained.',
                 shrink:      true,
                 label:       'Not Contains',
                 type:        'keyvalue',
                 value:       {},
               },
        },
        examples: {
          "Match On A Value" => {
                                  description: 'The input is returned if it matches on a value.',
                                  input: {
                                           name: "John",
                                         },
                                  config: {
                                    matches: { name: "John" }
                                  },
                                  result: {
                                            name: "John",
                                          }
                                },
          "Contains A Value" => {
                                  description: 'The input is returned if it contains a value.',
                                  input: {
                                           name: "John",
                                         },
                                  config: {
                                    contains: { name: "H" }
                                  },
                                  result: {
                                            name: "John",
                                          }
                                },
          }
      }
    end

    def process event, config

      differences = [:equal, :notequal, :contains, :notcontains]
        .select { |x| config[x].is_a? Hash }
        .map { |x| config[x].map { |k, v| { m: x, k: k, v1: v } } }
        .flatten
        .map { |x| x[:v2] = event[x[:k]] ; x }
        .map { |x| [x[:m], x[:v1], x[:v2]] }
        .reject { |x| self.send x[0], x[1], x[2] }

      differences.count == 0 ? event : nil

    end

    def equal a, b
      [a, b]
        .map { |x| numeric?(x) ? x.to_f : x }
        .map { |x| nice_string x }
        .group_by { |x| x }
        .count == 1
    end

    def notequal a, b
      equal(a, b) == false
    end

    def contains a, b
      return false unless b
      nice_string(b).include? a.downcase
    end

    def notcontains a, b
      contains(a, b) == false
    end

    def numeric? value
      Float(value) != nil rescue false
    end

    def nice_string value
      value.to_s.strip.downcase
    end

  end

end