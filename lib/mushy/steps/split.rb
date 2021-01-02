module Mushy

  class Split < Step

    def process event, config
      Masher.new.dig(config[:path], event)
    end

  end

end