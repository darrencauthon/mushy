module Mushy

  class Ls < Bash

    def self.details
      {
        name: 'Ls',
        description: 'Run the "ls" command.',
        config: {
          directory: {
                       description: 'The working directory in which the command will be run.',
                       type:        'text',
                       value:       '',
                     },
        },
      }
    end

    def process event, config

      config[:command] = 'ls'

      result = super event, config

      return result unless result[:success]

      result[:text].split("\n").map do |x|
        {
          name: x,
        }
      end

    end

  end

end

