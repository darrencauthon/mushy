module Mushy

  class ReadFile < Flux

    def self.details
      {
        name: 'ReadFile',
        description: 'Read a file.',
        config: {
          name: {
                  description: 'The name of the file to read.',
                  type:        'text',
                  value:       'file.csv',
                },
          directory: {
                  description: 'The directory in which to read the file. Leave blank for the current directory.',
                  type:        'text',
                  shrink:      true,
                  value:       '',
                },
          path: {
                  description: 'The path in the event to return the contents of the file.',
                  type:        'text',
                  value:       'content',
                },
        },
      }
    end

    def process event, config
      file = config[:name]

      file = File.join(config[:directory], file) if config[:directory].to_s != ''

      content = File.open(file).read

      {
        config[:path] => content
      }
    end

  end

end