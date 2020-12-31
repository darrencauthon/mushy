module Mushy
  
  class Bash < Step

    def process event
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