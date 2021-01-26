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
          headers: {
                     description: 'The values to include in the CSV, as well as the header values.',
                     type:        'keyvalue',
                     value:       {},
                   },
        },
      }
    end

    def process event, config
      records = event[config[:input_path].to_sym] || event[config[:input_path].to_s]

      headers = config[:headers]

      puts headers.inspect
      puts records.inspect
      {
        config[:output_path] => CSV.generate { |c| records.each { |x| c << headers.map { |h| x[h[0].to_sym] || x[h[0].to_s] } } }
      }
    end

  end

end
