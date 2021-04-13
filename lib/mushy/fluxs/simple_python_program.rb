module Mushy

  class SimplePythonProgram < Bash

    def self.default_config
      Mushy::Bash.details[:config].tap do |config|
        config.delete :command
        config.delete :directory
      end
    end

    def self.details
      nil
    end

    def process event, config

      lines = python_program(event, config)
                .split('\n')
                .map { |x| x.rstrip }
                .select { |x| x && x != '' }
                .map { |x| x.gsub('"', '\"') }

      config[:command] = "python -c \"#{lines.join(';')}\""

      result = super event, config

      return nil unless result[:success]

      adjust SymbolizedHash.new(JSON.parse(result[:text])), event, config

    end

    def adjust data, event, config
      data
    end

  end

end
