module Mushy
  
  class Bash < Flux

    def self.details
      config = {
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
      }
      table_content = '<table class="table is-bordered"><thead><tr><td>Field</td><td>Description</td></tr></thead>' + config.reduce("") { |t, i| "#{t}<tr><td>#{i[0]}</td><td>#{i[1][:description]}</td></tr>" } + "</table>"

      config.each do |k, v|
      end

      {
        name: 'Bash',
        description: 'Run a bash command.',
        config: config,
        documentation: {
          "Basic Usage" => '
The Bash flux will run a bash command and return the results.

' + table_content + '

<pre><code>
{
  "text": "bin\nblue_heart.png\nthe_output.txt\n",
  "success": true,
  "exit_code": 0
}
</code></pre>
          ',
                       }
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