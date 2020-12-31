require 'csv'

module Mushy
  
  class Csv < Step

    def process event, config
      data = event[config[:key]]

      headers = config[:headers].to_s.strip.downcase == 'true' ? true : false

      rows = CSV.new data, headers: headers

      rows.map do |row|
        if headers
          row.to_hash
        else
          record = {}
          row.each_with_index { |r, i| record[i.to_s] = r }
          record
        end
      end
    end

  end

end