module Mushy

  class SenseHatLedMatrix < SimplePythonProgram

    def self.details
      {
        name: 'SenseHatLedMatrix',
        description: 'Interface with the LED Matrix.',
        config: Mushy::SimplePythonProgram.default_config.tap do |config|
          config[:get_pixels] = {
                                  description: 'Specify the pixels you want returned as events. Use "all" to return all 64, 3,3 to return x:3 y:3, or "none" to return none.',
                                  type:        'text',
                                  shrink:      true,
                                  value:       'all',
                                }
          config[:set_pixel] = {
                                 description: 'Set a single pixel to the RGB color.',
                                 type:        'text',
                                 shrink:      true,
                                 value:       '',
                               }
          config[:rgb] = {
                            description: 'The RGB value as a comma-delimited list. Leave blank to not set a color.',
                            type:        'text',
                            shrink:      true,
                            value:       '',
                         }
          config[:clear] = {
                             description: 'The RGB color to apply to the entire grid.',
                             type:        'text',
                             shrink:      true,
                             value:       '',
                           }
        end
      }
    end

    def python_program event, config

      rgb = rgb_from config[:rgb]
      coordinates = coordinates_from config[:get_pixels]
      set_pixel_coordinates = coordinates_from config[:set_pixel]
      clear = rgb_from config[:clear]

      set_pixels_code = if rgb && set_pixel_coordinates
                          "sense.set_pixel(#{set_pixel_coordinates[:x]}, #{set_pixel_coordinates[:y]}, [#{rgb[:r]}, #{rgb[:g]}, #{rgb[:b]}])"
                        else
                          ''
                        end
      clear_pixels_code = if clear
                            "sense.clear(#{clear[:r]}, #{clear[:g]}, #{clear[:b]})"
                          else
                            ''
                          end
      get_pixels_code = if coordinates
                          "sense.get_pixel(#{coordinates[:x]}, #{coordinates[:y]})"
                        elsif config[:get_pixels].to_s.downcase == 'all'
                          'sense.get_pixels()'
                        else
                          '[]'
                        end
      hat = true ? 'sense_hat' : 'sense_emu'
      <<PYTHON
from #{hat} import SenseHat
import json
sense = SenseHat()
#{set_pixels_code}
#{clear_pixels_code}
value = json.dumps({"all": #{get_pixels_code}})
print(value)
PYTHON
    end

    def adjust data, event, config
      limit = 8

      coordinates = coordinates_from config[:get_pixels]

      records = coordinates ? [data[:all]] : data[:all]

      results = records.each_with_index.map do |item, index|
        {
          x: index % limit,
          y: index / limit,
          r: item[0],
          g: item[1],
          b: item[2],
        }
      end

      if coordinates
        results[0][:x] = coordinates[:x]
        results[0][:y] = coordinates[:y]
      end

      results
    end

    def rgb_from config
      color_split = config.to_s.split ','
      return nil unless color_split.count == 3
      return [:r, :g, :b].each_with_index
                          .reduce({}) { |t, i| t[i[0]] = color_split[i[1]].to_s.to_i ; t}
    end

    def coordinates_from config
      coordinate_split = config.to_s.split ','
      return nil unless coordinate_split.count == 2
      return [:x, :y].each_with_index
                      .reduce({}) { |t, i| t[i[0]] = coordinate_split[i[1]].to_s.to_i ; t}
    end

  end

end