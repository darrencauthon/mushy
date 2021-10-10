module Mushy

  class TwilioMessage < Bash

    def self.details
      {
        name: 'TwilioMessage',
        description: 'Send a Twilio Message.',
        config: {
          account_sid: {
                         description: 'Your Twilio Account SID.',
                         type:        'text',
                         value:       '{{twilio_account_sid}}',
                       },
          auth_token: {
                        description: 'Your Twilio Auth Token.',
                        type:        'text',
                        value:       '{{twilio_auth_token}}',
                      },
          from: {
                  description: 'From.',
                  type:        'text',
                  value:       '+1{{from}}',
                },
          to: {
                description: 'To.',
                type:        'text',
                value:       '+1{{to}}',
              },
          body: {
                  description: 'Body.',
                  type:        'text',
                  value:       '{{body}}',
                },
          media_url: {
                       description: 'Media URL.',
                       type:        'text',
                       value:       '',
                       shrink:      true,
                     },
        },
        examples: {
          "Basic Example" => {
                               description: "This is what a basic text message.",
                               input: { message: "Hello World!" },
                               config: {
                                 account_sid: 'Your Twilio Account SID',
                                 auth_token: 'Your Twilio Auth Token',
                                 from: '+15555555555',
                                 to: '+14444444444',
                                 body: '{{message}}',
                               },
                               result: {
                                         sid: "the sid",
                                         date_created: "Sun, 10 Oct 2021 20:16:48 +0000",
                                         date_updated: "Sun, 10 Oct 2021 20:16:48 +0000",
                                         date_sent: nil,
                                         account_sid: "account sid",
                                         to: "+15555555555",
                                         from: "+14444444444",
                                         messaging_service_sid: nil,
                                         body: "Hello World!",
                                         status: "queued",
                                         num_segments: "1",
                                         num_media: "0",
                                         direction: "outbound-api",
                                         api_version: "2010-04-01",
                                         price: nil,
                                         price_unit: "USD",
                                         error_code: nil,
                                         error_message: nil,
                                         uri: "/2010-04-01/Accounts/ABC/Messages/DEF.json",
                                         subresource_uris: {
                                           media: "/2010-04-01/Accounts/ABC/Messages/DEF/Media.json"
                                         }
                                       }
                             }
        },
        "A Failed Call" => {
          description: "This is what a failed call may look like.",
          result: {
                    code: 20003,
                    detail: "Your AccountSid or AuthToken was incorrect.",
                    message: "Authentication Error - invalid username",
                    more_info: "https://www.twilio.com/docs/errors/20003",
                    status: 401
                  }
        }
      }
    end

    def process event, config
      arguments = {
        from: "From",
        to: "To",
        body: "Body",
        media_url: "MediaUrl",
      }.select { |x| config[x].to_s != "" }
       .reduce("") { |t, i| "#{t} --data-urlencode \"#{i[1]}=#{config[i[0]]}\"" }

      config[:command] = "curl -X POST https://api.twilio.com/2010-04-01/Accounts/#{config[:account_sid]}/Messages.json -u #{config[:account_sid]}:#{config[:auth_token]} #{arguments}"

      result = super event, config

      JSON.parse result[:text]
    end

  end

end
