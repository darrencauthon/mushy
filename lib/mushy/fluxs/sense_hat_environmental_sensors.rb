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
        default_measurements = [:humidity, :temperature, :pressure]
        measurements.each do |measurement|
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

    def process event, config

      measurements_to_apply = self.class.measurements.reduce({}) { |t, i| t[i] = "get_#{i}"; t}

      call = measurements_to_apply.map { |m| "\"#{m[0]}\": sense.#{m[1]}()" }
                                  .join(',')
      call = "{#{call}}"

      commands = [
                   'from sense_hat import SenseHat',
                   'import json',
                   'sense = SenseHat()',
                   "value = json.dumps(#{call})",
                   'print(value)',
                 ]

      command = commands.map { |x| x.gsub('"', '\"')}.join(';')

      command = "python -c \"#{command}\""

      config[:command] = command

      result = super event, config

      return nil unless result[:success]

      JSON.parse result[:text]

    end

  end

end