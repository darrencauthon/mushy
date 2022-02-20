module Mushy

  class ReadFile < Flux

    def self.details
      {
        name: 'ReadFile',
        title: 'Read File',
        fluxGroup: { name: 'Files' },
        description: 'Read a file.',
        config: {
          file: {
                  description: 'The file to read.',
                  type:        'text',
                  value:       'file.csv',
                },
          directory: {
                  description: 'The directory in which to read the file. Leave blank for the current directory.',
                  type:        'text',
                  shrink:      true,
                  value:       '',
                },
          key: {
                 description: 'The key in the resulting event to return the contents of the file.',
                 type:        'text',
                 value:       'content',
               },
        },
        examples: {
          "Example" => {
                         description: 'Using this Flux to read the contents of a text file.',
                         input: {
                                  file: "data.csv"
                                },
                         config: {
                                   file: '{{file}}',
                                   key: 'csvdata'
                                 },
                         result: { csvdata: 'a,b,c\nd\n\e\f'}
                       },
        }
      }
    end

    def process event, config
      file = config[:file]

      file = File.join(config[:directory], file) if config[:directory].to_s != ''

      content = File.open(file).read

      {
        config[:key] => content
      }
    end

  end

end