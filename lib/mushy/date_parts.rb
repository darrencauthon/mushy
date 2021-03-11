module Mushy

  module DateParts

    def self.parse now
      {
        year: nil,
        month: nil,
        day: nil,
        hour: nil,
        minute: :min,
        second: :sec,
        nanosecond: :nsec,
        utc_offset: nil,
        weekday: :wday,
        day_of_month: :mday,
        day_of_year: :yday,
        string: :to_s,
        epoch_integer: :to_i,
        epoch_float: :to_f,
      }.reduce({}) do |t, i|
        method = i[1] || i[0]
        t[i[0]] = now.send method
        t
      end
    end

  end

end