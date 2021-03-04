module Mushy

  class Pdf < Browser

    def self.details
      details = Browser.details
      details['name'] = 'Pdf'
      details['description'] = 'Turn a URL into a PDF.'

      details[:config][:path] = {
         description: 'The path of the PDF file to save.',
         type:        'text',
         value:       'picture.pdf',
      }

      details[:config][:landscape] = {
         description: 'Build the PDF in landscape. Defaults to false.',
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
          path: the_config[:path],
      }

      options[:landscape] = true if the_config[:landscape].to_s == 'true'

      the_browser.pdf options

      options

    end

  end

end