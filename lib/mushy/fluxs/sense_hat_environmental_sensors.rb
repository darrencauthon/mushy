module Mushy

  class SimplePythonProgram < Bash

    def self.default_config
      Mushy::Bash.details[:config].tap do |config|
        config.delete :command
        config.delete :directory
      end
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

      JSON.parse result[:text]

    end

  end

  class SenseHatEnvironmentalSensors < SimplePythonProgram

    def self.details
      {
        name: 'SenseHatEnvironmentalSensors',
        description: 'Pull values from the Sense HAT environmental sensors.',
        config: Mushy::SimplePythonProgram.default_config,
      }.tap do |c|
        measurements
          .sort_by { |x| default_measurements.include?(x) ? 0 : 1 }
          .each do |measurement|
            c[:config][measurement] = {
                                        description: "Pull #{measurement}.",
                                        type:        'boolean',
                                        shrink:      true,
                                        value:       default_measurements.include?(measurement) ? 'true' : '',
                                      }
        end
      end
    end

    def self.measurements
      [
        :humidity,
        :temperature,
        :temperature_from_humidity,
        :temperature_from_pressure,
        :pressure,
      ]
    end

    def self.default_measurements
      [:humidity, :temperature, :pressure]
    end

    def python_program event, config
      values = self.class.measurements
                   .select { |x| config[x] == 'true' }
                   .reduce({}) { |t, i| t[i] = "get_#{i}"; t}
                   .map { |m| "\"#{m[0]}\": sense.#{m[1]}()" }
                   .join(',')

      <<PYTHON
from sense_hat import SenseHat
import json
sense = SenseHat()
value = json.dumps({#{values}})
print(value)
PYTHON
    end

  end

end