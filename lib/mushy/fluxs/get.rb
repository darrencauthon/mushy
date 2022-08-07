# frozen_string_literal: true

require 'faraday'

#
# Look at the content given by the bridge.
#
class Mushy::Get < Flux
  def self.details
    {
      name: 'Get',
      title: 'Make a GET call',
      fluxGroup: { name: 'Web' },
      description: 'Makes a GET call to a URL',
      config: {
        url: {
          description: 'The URL to visit.',
          type: 'text',
          value: 'https://www.google.com'
        },
        headers: {
          description: 'Headers for the web request.',
          type: 'keyvalue',
          shrink: true,
          value: {}
        }
      },
      examples: {
        'Successful Call' => {
          description: 'This will open https://www.google.com and return the result.',
          config: { url: 'https://www.google.com' },
          result: {
            url: 'https://www.google.com/',
            status: 200,
            title: 'Google',
            cookies: [
              {
                name: '1P_JAR',
                value: '2021-10-06-12',
                domain: '.google.com',
                path: '/',
                expires: 1636117150.583117,
                size: 19,
                httpOnly: false,
                secure: true,
                session: false,
                sameSite: 'None',
                priority: 'Medium'
              }
            ],
            headers: {},
            time: 1.486214604,
            body: '<html itemscope="" itemtype="http://schema.org/WebPage" lang="en">...</html>'
          }
        }
      }
    }
  end

  def process(_event, config) # rubocop:disable Metrics/MethodLength
    faraday = Faraday.new do |connection|
      connection.adapter Faraday.default_adapter
    end

    headers = config[:headers] || {}
    data = {}
    url = config[:url]

    response = faraday.get config[:url], data, headers

    {
      status: response.status,
      url: url,
      reason_phrase: response.reason_phrase,
      headers: response.headers,
      body: response.body
    }
  end
end
