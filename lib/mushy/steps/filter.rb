module Mushy
  
  class Filter < Step

    def process event, config
      matches = config[:equals]
                  .select { |k, v| event[k] != config[:equals][k] }
                  .count == 0
      matches ? event : nil
    end

  end

end