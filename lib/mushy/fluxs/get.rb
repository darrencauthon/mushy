# frozen_string_literal: true

require 'faraday'

#
# Look at the content given by the bridge.
#
class Mushy::Get < Flux
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
