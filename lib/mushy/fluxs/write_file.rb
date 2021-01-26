module Mushy

  class WriteFile < Flux

    def self.details
      {
        name: 'WriteFile',
        description: 'Write a file.',
        config: {
          name: {
                  description: 'The name of the file.',
                  type:        'text',
                  value:       'records',
                },
          directory: {
                  description: 'The directory in which to write the file. Leave blank for the current directory.',
                  type:        'text',
                  value:       'records',
                },
          path: {
                  description: 'The path to the data to write.',
                  type:        'text',
                  value:       'records',
                },
        },
      }
    end

    def process event, config
      data = event[config[:path].to_sym] || event[config[:path].to_s]

      File.open(config[:name], 'w') { |f| f.write data }

      {}
    end

  end

end
