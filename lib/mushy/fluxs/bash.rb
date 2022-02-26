class Mushy::Bash < Flux
  def self.details
    {
      name: 'Bash',
      title: 'Execute a command via bash',
      description: 'Run a bash command.',
      fluxGroup: { name: 'Execute' },
      config: {
        command: {
          description: 'The command to run in bash.',
          type: 'text',
          value: '{{command}}'
        },
        directory: {
          description: 'The working directory in which the command will be run.',
          type: 'text',
          shrink: true,
          value: ''
        }
      },
      examples: {
        'Successful Call' => {
          description: 'This will run the ls command and return the full bash result.',
          input: { command: 'ls' },
          result: {
            text: "bin\nblue_heart.png\nthe_output.txt\n",
            success: true,
            exit_code: 0
          }
        },
        'Failed Call' => {
          description: 'This is an example of what happens when the command fails.',
          input: { command: 'rm file_that_does_not_exist.txt' },
          result: {
            text: '',
            success: false,
            exit_code: 256
          }
        }
      }
    }
  end

  def process(_, config)
    command = config[:command]

    command = "cd #{config[:directory]};#{command}" if config[:directory]

    text = `#{command}`

    result = $?
    {
      text: text,
      success: result.success?,
      exit_code: result.to_i
    }
  end
end
