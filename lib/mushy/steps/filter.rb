module Mushy
  
  class Filter < Step

    def process event, config

      operations = config[:equal].map { |k, v| [:equal, event[k], v] } +
                   config[:notequal].map { |k, v| [:notequal, event[k], v] }
      
      matches = operations
        .reject { |x| self.send x[0], x[1], x[2] }
        .count == 0

      matches ? event : nil
    end

    def equal a, b
      [a, b]
        .map { |x| numeric?(x) ? x.to_f : x }
        .map { |x| x.to_s.strip.downcase }
        .group_by { |x| x }
        .count == 1
    end

    def notequal a, b
      equal(a, b) == false
    end

    def numeric? value
      Float(value) != nil rescue false
    end

  end

end