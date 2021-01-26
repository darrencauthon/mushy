module Mushy

  class WriteFile < Flux

    def self.details
      {
        name: 'WriteFile',
        description: 'Write a file.',
        config: {
          input_path: {
                        description: 'The path to the set of records to include in the CSV.',
                        type:        'text',
                        value:       'records',
                      },
        },
      }
    end

    def process event, config
        puts config.inspect
      data = event[config[:path].to_sym] || event[config[:path].to_s]
      puts data.inspect
      puts '^^^'

      File.open(config[:name], 'w') { |f| f.write data }

      nil
    end

  end

end
