module Mushy
  
  class Bash < Flux

    def self.details
      config = {
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
        examples: {
          "Sample Call" => {
                             description: 'This will run the ls command and return the full bash result.',
                             input: {
                                      command: "ls",
                                    },
                             result: {
                                       "text": "bin\nblue_heart.png\nthe_output.txt\n",
                                       "success": true,
                                       "exit_code": 0
                                     }
                           },
          }
      }
      config[:documentation] = build_documentation_from config
      config
    end

    def self.build_documentation_from config
      documentation = {
          "Basic Usage" => "
#{config[:description]}

" + '<table class="table is-bordered"><thead><tr><td>Field</td><td>Description</td></tr></thead>' + config[:config].reduce("") { |t, i| "#{t}<tr><td>#{i[0]}</td><td>#{i[1][:description]}</td></tr>" } + "</table>"
                      }

      if config[:examples]
        config[:examples].each do |item|
          documentation[item[0]] = "<pre><code>#{JSON.pretty_generate(item[1][:result])}</code></pre>"
        end
      end

      documentation
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