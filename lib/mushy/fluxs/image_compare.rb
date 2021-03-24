require 'imatcher'

module Mushy
  
  class ImageCompare < Flux

    def self.details
      {
        name: 'ImageCompare',
        description: 'Compare two images of the same size.',
        config: {
          file1: {
                   description: 'The first file to compare.',
                   type:        'text',
                   value:       '',
                 },
          file2: {
                   description: 'The second file to compare.',
                   type:        'text',
                   value:       '',
                 }
        },
      }
    end

    def process event, config
      cmp = Imatcher::Matcher.new threshold: 0.05

      result = cmp.compare(config[:file1], config[:file2])

      {
        match: result.match?,
        score: result.score,
        threshold: result.threshold,
      }
    end

  end

end
