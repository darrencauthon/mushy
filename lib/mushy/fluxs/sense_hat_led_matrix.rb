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
          config[:background_color] = {
                                        description: 'The RGB of the background, which is used in some API calls.',
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
          config[:show_letter] = {
                                   description: 'Show a single letter on the grid. Uses Rgb and Background Color.',
                                   type:        'text',
                                   shrink:      true,
                                   value:       '',
                                 }
          config[:show_message] = {
                                    description: 'Scroll a message across the grid. Uses Rgb and Background Color.',
                                    type:        'text',
                                    shrink:      true,
                                    value:       '',
                                  }
          config[:load_image] = {
                                  description: 'Load a 8x8 image.',
                                  type:        'text',
                                  shrink:      true,
                                  value:       '',
                                }
          config[:set_rotation] = {
                                    description: 'Rotate the image by these degrees.',
                                    type:        'select',
                                    options:     ['', '0', '90', '180', '270'],
                                    shrink:      true,
                                    value:       '',
                                  }
          config[:redraw] = {
                              description: 'Redraw.',
                              type:        'boolean',
                              shrink:      true,
                              value:       '',
                            }
          config[:low_light] = {
                              description: 'Use the low light to turn down the brightness.',
                              type:        'boolean',
                              shrink:      true,
                              value:       '',
                            }
          config[:flip_h] = {
                              description: 'Flips the image horizontally.',
                              type:        'boolean',
                              shrink:      true,
                              value:       '',
                            }
          config[:flip_v] = {
                              description: 'Flips the image vertically.',
                              type:        'boolean',
                              shrink:      true,
                              value:       '',
                            }
          config[:target] = {
                              description: 'The target of these commands. "hat" is a SenseHAT plugged into your Raspberry Pi, and "emu" is the SenseHAT emulator. Defaults to "hat".',
                              type:        'select',
                              options:     ['', 'hat' , 'emu'],
                              shrink:      true,
                              value:       '',
                            }
        end
      }
    end

    def python_program event, config

      commands = [
        :set_pixels_code_from,
        :clear_pixels_code_from,
        :show_letters_code_from,
        :show_message_code_from,
        :load_images_code_from,
        :set_rotation_code_from,
        :low_light_code_from,
        :flip_h_code_from,
        :flip_v_code_from,
      ].map { |x| self.send x, event, config }
       .select { |x| x.to_s != '' }
       .join("\n")

      hat = config[:target] == 'emu' ? 'sense_emu' : 'sense_hat'

      <<PYTHON
from #{hat} import SenseHat
import json
sense = SenseHat()
#{commands}
value = json.dumps({"all": #{get_pixels_code_from(event, config)}})
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

      results.each do |record|
        record[:coordinate] = "#{record[:x]},#{record[:y]}"
        record[:rgb] = "#{record[:r]},#{record[:g]},#{record[:b]}"
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

    def set_pixels_code_from event, config
      rgb = rgb_from config[:rgb]
      set_pixel_coordinates = coordinates_from config[:set_pixel]
      return '' unless rgb
      return '' unless set_pixel_coordinates
      coordinates = [set_pixel_coordinates[:x], set_pixel_coordinates[:y]]
      colors      = [rgb[:r], rgb[:g], rgb[:b]]
      "sense.set_pixel(#{coordinates[0]}, #{coordinates[1]}, [#{colors[0]}, #{colors[1]}, #{colors[2]}])"
    end

    def clear_pixels_code_from event, config
      clear = rgb_from config[:clear]
      return '' unless clear
      "sense.clear(#{clear[:r]}, #{clear[:g]}, #{clear[:b]})"
    end

    def show_letters_code_from event, config
      return '' if config[:show_letter].to_s == ''

      rgb = rgb_from config[:rgb]
      background_color = rgb_from config[:background_color]

      args = ["\"#{config[:show_letter]}\""]
      args << "text_colour=[#{rgb[:r]}, #{rgb[:g]}, #{rgb[:b]}]" if rgb
      args << "back_colour=[#{background_color[:r]}, #{background_color[:g]}, #{background_color[:b]}]" if background_color
      "sense.show_letter(#{args.join(',')})"
    end

    def show_message_code_from event, config
      return '' if config[:show_message].to_s == ''

      rgb = rgb_from config[:rgb]
      background_color = rgb_from config[:background_color]

      args = ["\"#{config[:show_message]}\""]
      args << "text_colour=[#{rgb[:r]}, #{rgb[:g]}, #{rgb[:b]}]" if rgb
      args << "back_colour=[#{background_color[:r]}, #{background_color[:g]}, #{background_color[:b]}]" if background_color
      "sense.show_message(#{args.join(',')})"
    end

    def load_images_code_from event, config
      return '' if config[:load_image].to_s == ''

      args = ["\"#{config[:load_image]}\""]
      args << config[:redraw].to_s.capitalize if config[:redraw].to_s != ''
      "sense.load_image(#{args.join(',')})"
    end

    def set_rotation_code_from event, config
      return '' if config[:set_rotation].to_s == ''
      args = ["#{config[:set_rotation]}"]
      args << config[:redraw].to_s.capitalize if config[:redraw].to_s != ''
      "sense.set_rotation(#{args.join(',')})"
    end

    def low_light_code_from event, config
      return '' if config[:low_light].to_s == ''
      "sense.low_light = #{config[:low_light].capitalize}"
    end

    def flip_h_code_from event, config
      return '' unless config[:flip_h].to_s == 'true'
      args = []
      args << config[:redraw].to_s.capitalize if config[:redraw].to_s != ''
      "sense.flip_h(#{args.join(',')})"
    end

    def flip_v_code_from event, config
      return '' unless config[:flip_v].to_s == 'true'
      args = []
      args << config[:redraw].to_s.capitalize if config[:redraw].to_s != ''
      "sense.flip_v(#{args.join(',')})"
    end

    def get_pixels_code_from event, config
      get_pixel_coordinates = coordinates_from config[:get_pixels]

      if get_pixel_coordinates
        "sense.get_pixel(#{get_pixel_coordinates[:x]}, #{get_pixel_coordinates[:y]})"
      elsif config[:get_pixels].to_s.downcase == 'all'
        'sense.get_pixels()'
      else
        '[]'
      end
    end

  end

end