module Mushy
  
  class Filter < Step

    def process event, config
      matches = config[:filter]
                  .select { |k, v| event[k] != config[:filter][k] }
                  .count == 0
      matches ? event : nil
    end

  end

end