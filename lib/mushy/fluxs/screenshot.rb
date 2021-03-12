module Mushy

  class Screenshot < Browser

    def self.details
      details = Browser.details
      details['name'] = 'Screenshot'
      details['description'] = 'Take a screenshot of the browser.'

      details[:config][:path] = {
         description: 'The path of the file to save.',
         type:        'text',
         value:       'picture.jpg',
      }
      details[:config][:quality] = {
         description: 'The quality of the image, a value beteen 0-100. Only applies to jpg.',
         type:        'integer',
         shrink:      true,
         value:       '',
      }
      details[:config][:full] = {
         description: 'Take a screenshot of the entire page. If false, the screenshot is limited to the viewport.',
         type:        'boolean',
         shrink:      true,
         value:       '',
      }
      details
    end

    def adjust input

      the_browser = input[:browser]
      the_result  = input[:result]
      the_config  = input[:config]

      options = {
          path:    the_config[:path],
          full:    ['true', ''].include?(the_config[:full].to_s),
          quality: (the_config[:quality].to_s == '' ? '100' : the_config[:quality]).to_i
      }

      the_browser.screenshot options

      options.merge the_result

    end

  end

end