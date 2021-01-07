module Mushy
  
  class Filter < Step

    def process event, config

      matches = config[:equal]
                  .reject { |k, v| event[k] == config[:equal][k] }
                  .count == 0

      return nil unless matches

      matches = config[:notequal]
                  .reject { |k, v| event[k] != config[:notequal][k] }
                  .count == 0

      matches ? event : nil
    end

  end

end