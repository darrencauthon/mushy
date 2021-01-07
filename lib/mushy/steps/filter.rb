module Mushy
  
  class Filter < Step

    def process event, config

      matches = config[:equal]
                  .reject { |k, v| equal event[k], v }
                  .count == 0

      return nil unless matches

      matches = config[:notequal]
                  .reject { |k, v| notequal event[k], v }
                  .count == 0

      matches ? event : nil
    end

    def equal a, b
      a == b
    end

    def notequal a, b
      equal(a, b) == false
    end

  end

end