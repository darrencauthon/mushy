module Mushy
  class Masher
    def mash one, two
      Liquid::Template.parse(one).render two
    end
  end
end