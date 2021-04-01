module Mushy

  class SenseHatLedMatrix < SimplePythonProgram

    def self.details
      {
        name: 'SenseHatLedMatrix',
        description: 'Interface with the LED Matrix.',
        config: Mushy::SimplePythonProgram.default_config,
      }
    end

    def python_program event, config
      <<PYTHON
from sense_hat import SenseHat
import json
sense = SenseHat()
value = json.dumps({"all": sense.get_pixels()})
print(value)
PYTHON
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