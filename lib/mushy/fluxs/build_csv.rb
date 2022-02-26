require 'csv'

class Mushy::BuildCsv < Mushy::Flux
  def self.details
    {
      name: 'BuildCsv',
      title: 'Build CSV',
      description: 'Build a CSV.',
      fluxGroup: { name: 'CSV' },
      config: {
        input_path: {
          description: 'The path to the set of records to include in the CSV.',
          type: 'text',
          value: 'records'
        },
        output_path: {
          description: 'The path to the CSV content in the outgoing event.',
          type: 'text',
          value: 'records'
        },
        headers: {
          description: 'The values to include in the CSV, as well as the header values.',
          type: 'keyvalue',
          value: {}
        },
        header_row: {
          description: 'Include a header row?',
          type: 'boolean',
          value: true
        }
      },
      examples: {
        'Build a Simple CSV' => {
          description: 'Converts a set of records to a CSV.',
          input: {
              things: [
                { name: 'Apple', color: 'Red' },
                { name: 'Banana', color: 'Yellow' },
                { name: 'Pear', color: 'Green' }
              ]
          },
          config: {
            input_path: 'things',
            output_path: 'records',
            headers: { name: 'Name', color: 'Color' },
            header_row: true
          },
          result: {
            records: 'Name,Color\nApple,Red\nBanana,Yellow\nPear,Green\n'
          }
        },
      }
    }
  end

  def process(event, config)
    records = event[config[:input_path].to_sym] || event[config[:input_path].to_s]

    headers = config[:headers]

    {
      config[:output_path] => CSV.generate do |c|
        c << headers.map { |h| h[1] } if config[:header_row].to_s == 'true'
        records.each { |x| c << headers.map { |h| x[h[0].to_sym] || x[h[0].to_s] } }
      end
    }
  end
end
