module Mushy

  class SenseHatEnvironmentalSensors < Bash

    def self.details
      details = Browser.details
      details['name'] = 'SenseHatEnvironmentalSensors'
      details['description'] = 'Pull values from the Sense HAT environmental sensors.'

      details[:config][:quality] = {
         description: 'Something',
         type:        'text',
         shrink:      true,
         value:       '',
      }
      details
    end

    def process event, config
      commands = [
                   'from sense_hat import SenseHat',
                   'import json',
                   'sense = SenseHat()',
                   'value = json.dumps({"pressure": sense.get_pressure()})',
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