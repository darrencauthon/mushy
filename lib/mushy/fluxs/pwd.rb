module Mushy

  class Pwd < Bash

    def self.details
      {
        name: 'Pwd',
        description: 'Run the "pwd" command.',
        config: Mushy::Bash.details[:config].tap { |c| c.delete :command },
      }
    end

    def process event, config

      config[:command] = 'pwd'

      result = super event, config

      return result unless result[:success]

      {
        pwd: result[:text].to_s.strip
      }

    end

  end

end