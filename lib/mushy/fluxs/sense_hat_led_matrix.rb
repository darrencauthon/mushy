module Mushy

  class SenseHatLedMatrix < SimplePythonProgram

    def self.details
      {
        name: 'SenseHatLedMatrix',
        description: 'Interface with the LED Matrix.',
        config: Mushy::SimplePythonProgram.default_config.tap do |config|
          [:x, :y, :r, :g, :b].each do |key|
            config[key] = {
                            description: "The #{key} value.",
                            type:        'text',
                            value:       "{{#{key}}}",
                          }
          end
        end
      }
    end

    def python_program event, config
      set_pixels = if config[:x] && config[:y]
                     "sense.set_pixel(#{config[:x]}, #{config[:y]}, [#{config[:r]}, #{config[:g]}, #{config[:b]}])"
                   else
                     ""
                   end
      command = <<PYTHON
from sense_hat import SenseHat
import json
sense = SenseHat()
#{set_pixels}
value = json.dumps({"all": sense.get_pixels()})
print(value)
PYTHON
      command
    end

    def adjust data
      limit = 8
      data[:all].each_with_index.map do |item, index|
        {
          x: index % limit,
          y: index / limit,
          r: item[0],
          g: item[1],
          b: item[2],
        }
      end
    end

  end

end