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
      }
    end

    def process event, config
      command = config[:command]

      text = `#{command}`

      result = $?
      {
        'text' => text,
        'success' => result.success?,
        'exit_code' => result.to_i,
      }
    end

  end

end