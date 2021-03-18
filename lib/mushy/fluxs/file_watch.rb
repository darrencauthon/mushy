require 'csv'

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
      event = {}
      puts 'k'
      block.call event
    end

    def process event, config
      nil
    end

  end

end