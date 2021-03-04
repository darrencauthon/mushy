require 'csv'

module Mushy
  
  class ReadCsv < Flux

    def self.details
      {
        name: 'ReadCsv',
        description: 'Read CSV content into events.',
        config: {
          data: {
                 description: 'The data to convert to a CSV.',
                 type:        'text',
                 value:       '{{data}}',
               },
          headers: {
                     description: 'The CSV contains headers. Defaults to false.',
                     type:        'boolean',
                     shrink:      true,
                     value:       '',
                   },
        },
      }
    end

    def process event, config
      data = config[:data]

      headers = config[:headers].to_s.strip.downcase == 'true'

      rows = CSV.new data, headers: headers

      rows.map do |row|
        if headers
          row.to_hash
        else
          record = {}
          row.each_with_index { |r, i| record[("a".ord + i).chr] = r }
          record
        end
      end
    end

  end

end