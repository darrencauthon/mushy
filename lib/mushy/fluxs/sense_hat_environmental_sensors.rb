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
        #c[:config][:recursive] = {
                                   #description: 'Pull files recursively.',
                                   #type:        'boolean',
                                   #shrink:      true,
                                   #value:       '',
                                 #}
      end
    end

    def process event, config

      measurements = {
        pressure: "get_pressure",
      }
      call = measurements.map { |m| "\"#{m[0]}\": sense.#{m[1]}()" }
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