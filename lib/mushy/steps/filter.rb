module Mushy
  
  class Filter < Step

    def process event, config

      matches = config[:equal]
                  .reject { |k, v| event[k] == config[:equal][k] }
                  .count == 0

      matches ? event : nil
    end

  end

end