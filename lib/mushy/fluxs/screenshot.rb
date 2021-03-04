module Mushy

  class Screenshot < Browser

    def self.details
      details = Browser.details
      details['name'] = 'Screenshot'
      details['description'] = 'Take a screenshot of the browser.'
      details
    end

    def special_browser_action browser, result
      browser.screenshot(path: 'picture.png')
      result
    end

  end

end