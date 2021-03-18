require 'listen'

module Mushy

  class FileWatch < Flux

    def self.details
      {
        name: 'FileWatch',
        description: 'Watch for file changes.',
        config: {
          directory: {
                       description: 'The directory to watch.',
                       type:        'text',
                       value:       '',
                     },
        },
      }
    end

    def loop &block

      directory = config[:directory].to_s != '' ? config[:directory] : Dir.pwd

      listener = Listen.to(directory) do |modified, added, removed|
        the_event = {
                      modified: modified,
                      added: added,
                      removed: removed,
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