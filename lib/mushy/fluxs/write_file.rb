module Mushy

  class WriteFile < Flux

    def self.details
      {
        name: 'WriteFile',
        title: 'Write File',
        description: 'Write a file.',
        config: file_saving_config.merge({
                  data: {
                          description: 'The text to write. You can use Liquid templating here to pull data from the event, or write hardcoded data.',
                          type:        'text',
                          value:       '{{data}}',
                        },
                }),
        examples: {
          "Example" => {
                         description: 'Using this Flux to write the contents of a text file. Details about the file are returned.',
                         input: {
                                  file: "data.csv",
                                  content: "a,b,c\nd,e,f",
                                },
                         config: {
                                   file: '{{file}}',
                                   data: '{{content}}'
                                 },
                         result: {
                                   file: {
                                     inode: "439540",
                                     hard_links: 1,
                                     owner: "pi",
                                     group: "pi",
                                     size: 3,
                                     date: {
                                       year: 2021,
                                       month: 10,
                                       day: 7,
                                       hour: 15,
                                       minute: 41,
                                       second: 14,
                                       nanosecond: 163590058,
                                       utc_offset: -18000,
                                       weekday: 4,
                                       day_of_month: 7,
                                       day_of_year: 280,
                                       string: "2021-10-07 15:41:14 -0500",
                                       epoch_integer: 1633639274,
                                       epoch_float: 1633639274.1635902,
                                       seconds_ago: 0.018665617
                                    },
                                     name: "file.csv",
                                     type: "-",
                                     owner_permission: "rw-",
                                     group_permission: "r--",
                                     other_permission: "r--",
                                     directory: "/home/pi/Desktop/mushy",
                                     path: "/home/pi/Desktop/mushy/file.csv"
                                  }
                                }
                       },
        }
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