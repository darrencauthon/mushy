module Mushy

  class Pdf < Browser

    def self.details
      details = Browser.details
      details[:name] = 'Pdf'
      details[:title] = 'PDF'
      details[:description] = 'Turn a URL into a PDF.'

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

      details.tap do |config|
        config[:examples] = {
          "PDF of google.com" => {
                                 description: 'This will open https://www.google.com and take a screenshot.',
                                 config: {
                                           url: "https://www.google.com",
                                           file: 'file.pdf'
                                         },
                                 result: {
                                           url: "https://www.google.com/",
                                           status: 200,
                                           title: "Google",
                                           cookies: [
                                           {
                                             name: "1P_JAR",
                                             value: "2021-10-07-21",
                                             domain: ".google.com",
                                             path: "/",
                                             expires: 1636232420.005369,
                                             size: 19,
                                             httpOnly: false,
                                             secure: true,
                                             session: false,
                                             sameSite: "None",
                                             priority: "Medium"
                                            }
                                          ],
                                          headers: {},
                                          time: 1.520785498,
                                          body: "...",
                                          options: {
                                            path: "file.pdf",
                                            full: true,
                                            quality: 100
                                          },
                                          file: {
                                            inode: "439545",
                                            hard_links: 1,
                                            owner: "pi",
                                            group: "pi",
                                            size: 54269,
                                            date: {
                                              year: 2021,
                                              month: 10,
                                              day: 7,
                                              hour: 16,
                                              minute: 0,
                                              second: 20,
                                              nanosecond: 444437482,
                                              utc_offset: -18000,
                                              weekday: 4,
                                              day_of_month: 7,
                                              day_of_year: 280,
                                              string: "2021-10-07 16:00:20 -0500",
                                              epoch_integer: 1633640420,
                                              epoch_float: 1633640420.4444375,
                                              seconds_ago: 0.016297478
                                            },
                                            name: "file.pdf",
                                            type: "-",
                                            owner_permission: "rw-",
                                            group_permission: "r--",
                                            other_permission: "r--",
                                            directory: "/home/pi/Desktop/mushy",
                                            path: "/home/pi/Desktop/mushy/file.pdf"
                                          }
                                        }
                               },
        }
      end
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

      {
        options: options,
        file: Mushy::Ls.new.process({}, { path: options[:path] })[0]
      }

    end

  end

end