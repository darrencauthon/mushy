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

      rgb = rgb_from config
      coordinates = coordinates_from config

      set_pixels = if rgb && coordinates
                     "sense.set_pixel(#{coordinates[:x]}, #{coordinates[:y]}, [#{rgb[:r]}, #{rgb[:g]}, #{rgb[:b]}])"
                   elsif rgb
                     "sense.clear(#{rgb[:r]}, #{rgb[:g]}, #{rgb[:b]})"
                   else
                     ''
                   end
      <<PYTHON
from sense_hat import SenseHat
import json
sense = SenseHat()
#{set_pixels}
value = json.dumps({"all": sense.get_pixels()})
print(value)
PYTHON
    end

    def adjust data, event, config
      limit = 8
      data[:all].each_with_index.map do |item, index|
        {
          x: index % limit,
          y: index / limit,
          r: item[0],
          g: item[1],
          b: item[2],
        }
      end.select { |hey| config[:x].to_s == '' || (hey[:x].to_s == config[:x].to_s && hey[:y].to_s == config[:y].to_s ) }
    end

    def rgb_from config
      colors = [:r, :g, :b].reduce({}) { |t, i| t[i] = config[i].to_s; t }
      return nil unless colors.select { |x| x[1] != '' }.any?
      colors.reduce({}) { |t, i| t[i[0]] = i[1].to_i; t }
    end

    def coordinates_from config
      return nil unless config[:x].to_s != '' && config[:y].to_s != ''
      [:x, :y].reduce({}) { |t, i| t[i] = config[i].to_s.to_i; t }
    end

  end

end