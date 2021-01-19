module Mushy
  
  class Bash < Step

    def details
      {
        name: 'Bash',
        description: 'Run a bash command.',
        command: {
                   description: 'The command to run in bash.',
                   type:        'text',
                 },
        directory: {
                     description: 'The working directory in which the command will be run.',
                     type:        'text',
                   },
      }
    end

    def process event, config
      command = config[:command]

      command = "cd #{config[:directory]};#{command}" if config[:directory]

      text = `#{command}`

      result = $?
      {
        text: text,
        success: result.success?,
        exit_code: result.to_i,
      }
    end

  end

  class Ls < Bash

    def details
      {
        name: 'LS',
        description: 'Run the "ls" command.',
        directory: {
                     description: 'The working directory in which the command will be run.',
                     type:        'text',
                   },
      }
    end

    def process event, config

      config[:command] = 'ls'

      result = super event, config

      return result unless result[:success]

      result[:text].split("\n").map do |x|
        {
          result: x,
        }
      end
    end

  end

end