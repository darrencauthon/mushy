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
        end
      }
    end

    def python_program event, config

      rgb = rgb_from config[:rgb]
      background_color = rgb_from config[:background_color]
      get_pixel_coordinates = coordinates_from config[:get_pixels]
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
      get_pixels_code = if get_pixel_coordinates
                          "sense.get_pixel(#{get_pixel_coordinates[:x]}, #{get_pixel_coordinates[:y]})"
                        elsif config[:get_pixels].to_s.downcase == 'all'
                          'sense.get_pixels()'
                        else
                          '[]'
                        end
      show_letters_code = if config[:show_letter].to_s != ''
                            args = ["\"#{config[:show_letter]}\""]
                            args << "text_colour=[#{rgb[:r]}, #{rgb[:g]}, #{rgb[:b]}]" if rgb
                            args << "back_colour=[#{background_color[:r]}, #{background_color[:g]}, #{background_color[:b]}]" if background_color
                            "sense.show_letter(#{args.join(',')})"
                          else
                            ''
                          end
      show_message_code = if config[:show_message].to_s != ''
                            args = ["\"#{config[:show_message]}\""]
                            args << "text_colour=[#{rgb[:r]}, #{rgb[:g]}, #{rgb[:b]}]" if rgb
                            args << "back_colour=[#{background_color[:r]}, #{background_color[:g]}, #{background_color[:b]}]" if background_color
                            "sense.show_message(#{args.join(',')})"
                          else
                            ''
                          end
      load_images_code = if config[:load_image].to_s != ''
                           args = ["\"#{config[:load_image]}\""]
                           args << config[:redraw].to_s.capitalize if config[:redraw].to_s != ''
                           "sense.load_image(#{args.join(',')})"
                         else
                           ''
                         end
      set_rotation_code = if config[:set_rotation].to_s != ''
                            args = ["#{config[:set_rotation]}"]
                            args << config[:redraw].to_s.capitalize if config[:redraw].to_s != ''
                            "sense.set_rotation(#{args.join(',')})"
                          else
                            ''
                          end
      low_light_code = if config[:low_light].to_s != ''
                         "sense.low_light = #{config[:low_light].capitalize}"
                       else
                         ''
                       end
      flip_h_code = if config[:flip_h].to_s == 'true'
                      args = []
                      args << config[:redraw].to_s.capitalize if config[:redraw].to_s != ''
                      "sense.flip_h(#{args.join(',')})"
                    else
                      ''
                    end
      flip_v_code = if config[:flip_v].to_s == 'true'
                      args = []
                      args << config[:redraw].to_s.capitalize if config[:redraw].to_s != ''
                      "sense.flip_v(#{args.join(',')})"
                    else
                      ''
                    end
      hat = true ? 'sense_hat' : 'sense_emu'
      <<PYTHON
from #{hat} import SenseHat
import json
sense = SenseHat()
#{set_pixels_code}
#{clear_pixels_code}
#{show_letters_code}
#{show_message_code}
#{load_images_code}
#{set_rotation_code}
#{low_light_code}
#{flip_h_code}
#{flip_v_code}
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

  end

end