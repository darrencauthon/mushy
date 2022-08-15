# frozen_string_literal: true

require 'faraday'

#
# A GET request.
#
class Mushy::Get < Mushy::Flux
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
        },
        params: {
          description: 'Parameters for the URL.',
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
    args = {
      params: config[:params],
      headers: config[:headers]
    }

    faraday = Faraday.new(**args) do |connection|
      connection.adapter Faraday.default_adapter
    end

    start = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    response = faraday.get config[:url]
    time = Process.clock_gettime(Process::CLOCK_MONOTONIC) - start

    url = response.instance_variable_get(:@env).url.to_s

    {
      status: response.status,
      url: url,
      time: time,
      reason_phrase: response.reason_phrase,
      headers: response.headers,
      body: response.body
    }
  end
end
