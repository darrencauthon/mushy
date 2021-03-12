module Mushy
  
  class Bash < Flux

    def self.details
      {
        name: 'Bash',
        description: 'Run a bash command.',
        config: {
          command: {
                     description: 'The command to run in bash.',
                     type:        'text',
                     value:       '{{command}}',
                   },
          directory: {
                       description: 'The working directory in which the command will be run.',
                       type:        'text',
                       shrink:      true,
                       value:       '',
                     },
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

end