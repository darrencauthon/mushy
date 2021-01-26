require 'csv'

module Mushy

  class BuildCsv < Flux

    def self.details
      {
        name: 'BuildCsv',
        description: 'Build a CSV.',
        config: {
          input_path: {
                        description: 'The path to the set of records to include in the CSV.',
                        type:        'text',
                        value:       'records',
                      },
          output_path: {
                         description: 'The path to the CSV content in the outgoing event.',
                         type:        'text',
                         value:       'records',
                       },
        },
      }
    end

    def process event, config
      records = event[config[:input_path].to_sym] || event[config[:input_path].to_s]

      puts records.inspect
      {
        config[:output_path] => CSV.generate { |c| records.each { |x| c << [x[:a]] } }
      }
    end

  end

end
