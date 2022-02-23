require 'listen'

module Mushy

  class FileWatch < Flux

    def self.details
      {
        name: 'FileWatch',
        title: 'Start a flow when files change',
        fluxGroup: { name: 'Starters', position: 0 },
        description: 'Watch for file changes.',
        config: {
          directory: {
                       description: 'The directory to watch, defaults to the current directory.',
                       type:        'text',
                       shrink:      true,
                       value:       '',
                     },
        },
        examples: {
          "Files Added" => {
                             description: 'When a file is added, this type of result will be returned.',
                             result: {
                                       modified: [],
                                       added: ["/home/pi/Desktop/mushy/bin/hey.txt"],
                                       removed:[]
                                     }
                           },
          "Files Removed" => {
                               description: 'When a file is deleted, this type of result will be returned.',
                               result: {
                                         modified: [],
                                         added: [],
                                         removed:["/home/pi/Desktop/mushy/mushy-0.15.3.gem"]
                                       }
                             },
          "Files Modified" => {
                                description: 'When a file is modified, this type of result will be returned.',
                                result: {
                                          modified: ["/home/pi/Desktop/mushy/lib/mushy/fluxs/environment.rb"],
                                          added: [],
                                          removed:[]
                                        }
                              },
        }
      }
    end

    def loop &block

      directory = config[:directory].to_s != '' ? config[:directory] : Dir.pwd

      listener = Listen.to(directory) do |modified, added, removed|
        the_event = {
                      modified: modified.map { |f| Mushy::Ls.new.process({}, { path: f })[0] },
                      added: added.map { |f| Mushy::Ls.new.process({}, { path: f })[0] },
                      removed: removed.map { |f| Mushy::Ls.new.process({}, { path: f })[0] },
                    }
        block.call the_event
      end

      listener.start

      sleep

    end

    def process event, config
      event
    end

  end

end