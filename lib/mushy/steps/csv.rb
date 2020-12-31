require 'csv'

module Mushy
  
  class Csv < Step

    def process event, config
      data = event[config[:key]]
      rows = CSV.new data, headers: false

      rows.map do |row|
        record = {}
        row.each_with_index { |r, i| record[i.to_s] = r }
        record
      end
    end

  end

end