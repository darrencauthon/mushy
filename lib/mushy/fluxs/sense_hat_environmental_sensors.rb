module Mushy

  class SenseHatEnvironmentalSensors < SimplePythonProgram

    def self.details
      {
        name: 'SenseHatEnvironmentalSensors',
        title: 'Read Environmental Sensors',
        description: 'Pull values from the Sense HAT environmental sensors.',
        fluxGroup: { name: 'SenseHAT' },
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