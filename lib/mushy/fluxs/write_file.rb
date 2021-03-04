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
                  value:       'file.csv',
                },
          directory: {
                  description: 'The directory in which to write the file. Leave blank for the current directory.',
                  type:        'text',
                  value:       '',
                },
          data: {
                  description: 'The text to write. You can use Liquid templating here to pull data from the event, or write hardcoded data.',
                  type:        'text',
                  value:       '{{data}}',
                },
        },
      }
    end

    def process event, config
      file = config[:name]

      file = File.join(config[:directory], file) if config[:directory].to_s != ''

      File.open(file, 'w') { |f| f.write config[:data] }

      {}
    end

  end

end