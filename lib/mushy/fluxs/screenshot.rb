module Mushy

  class Screenshot < Browser

    def self.details
      details = Browser.details
      details[:name] = 'Screenshot'
      details[:description] = 'Take a screenshot of the browser. This works the same as the Browser, but with a screenshot at the end.'

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
      details.tap do |config|
        config[:examples] = {
          "Screenshot of google.com" => {
                                 description: 'This will open https://www.google.com and take a screenshot.',
                                 config: {
                                           url: "https://www.google.com",
                                           file: 'file.jpg'
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
                                            path: "file.jpg",
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
                                            name: "file.jpg",
                                            type: "-",
                                            owner_permission: "rw-",
                                            group_permission: "r--",
                                            other_permission: "r--",
                                            directory: "/home/pi/Desktop/mushy",
                                            path: "/home/pi/Desktop/mushy/file.jpg"
                                          }
                                        }
                               },
        }
        config[:fluxGroup] = { name: 'Export' }
      end
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