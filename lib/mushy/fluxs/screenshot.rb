module Mushy

  class Screenshot < Browser

    def self.details
      details = Browser.details
      details[:name] = 'Screenshot'
      details[:description] = 'Take a screenshot of the browser.'

      details[:config].merge!(Mushy::WriteFile.file_saving_config.tap do |x|
        x[x.keys.first][:value] = 'file.jpg'
      end)

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

      file = Mushy::WriteFile.get_file_from the_config
      options = {
          path:    file,
          full:    ['true', ''].include?(the_config[:full].to_s),
          quality: (the_config[:quality].to_s == '' ? '100' : the_config[:quality]).to_i
      }

      the_browser.screenshot options

      the_result[:options] = options
      the_result[:file] = Mushy::Ls.new.process({}, { path: file })[0]

      the_result

    end

  end

end