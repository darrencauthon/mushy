module Mushy

  class WriteFile < Flux

    def self.details
      {
        name: 'WriteFile',
        description: 'Write a file.',
        config: file_saving_config.merge({
                  data: {
                          description: 'The text to write. You can use Liquid templating here to pull data from the event, or write hardcoded data.',
                          type:        'text',
                          value:       '{{data}}',
                        },
                }),
      }
    end

    def self.file_saving_config
      {
        name: {
                description: 'The name of the file.',
                type:        'text',
                value:       'file.csv',
              },
        directory: {
                     description: 'The directory in which to write the file. Leave blank for the current directory.',
                     shrink:      true,
                     type:        'text',
                     value:       '',
                   },
        }
    end

    def self.get_file_from config
      file = config[:name]
      file = File.join(config[:directory], file) if config[:directory].to_s != ''
      file
    end

    def process event, config
      file = self.class.get_file_from config

      File.open(file, 'w') { |f| f.write config[:data] }

      {
        file: Mushy::Ls.new.process({}, { path: file })[0]
      }
    end

  end

end