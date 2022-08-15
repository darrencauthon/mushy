# frozen_string_literal: true

require 'faraday'

#
# A PATCH request.
#
class Mushy::Patch < Mushy::HttpOperation
  def self.details
    super.merge({
                  examples: {
                    'Successful Call' => {
                      description: "This will send a #{operation.upcase} to https://www.google.com.",
                      config: { url: 'https://www.google.com' },
                      result: {
                        status: 400,
                        url: 'https://www.google.com',
                        time: 0.12829399993643165,
                        reason_phrase: 'OK',
                        headers: {
                          'access-control-allow-origin': '*',
                          'content-type': 'application/json; charset=utf-8',
                          'content-length': '193',
                          'keep-alive': 'timeout=5'
                        },
                        body: '{}'
                      }
                    }
                  }
                })
  end
end
