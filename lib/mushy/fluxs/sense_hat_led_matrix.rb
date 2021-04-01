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
      { hey: data[:all][0] }
    end

  end

end