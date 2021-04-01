module Mushy

  class SenseHatEnvironmentalSensors < Bash

    def self.details
      {
        name: 'SenseHatEnvironmentalSensors',
        description: 'Pull values from the Sense HAT environmental sensors.',
        config: Mushy::Bash.details[:config].tap do |config|
          config.delete :command
          config.delete :directory
        end,
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

    def a_simple_python_program_for event, config
      values = self.class.measurements
                   .select { |x| config[x] == 'true' }
                   .reduce({}) { |t, i| t[i] = "get_#{i}"; t}
                   .map { |m| "\"#{m[0]}\": sense.#{m[1]}()" }
                   .join(',')

      program = <<PYTHON
from sense_hat import SenseHat
import json
sense = SenseHat()
value = json.dumps({#{values}})
print(value)
PYTHON
    end

    def process event, config

      lines = a_simple_python_program_for(event, config)
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

end