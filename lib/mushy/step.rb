module Mushy

  class Step

    attr_accessor :id
    attr_accessor :parent_steps
    attr_accessor :config
    attr_accessor :masher

    def initialize
      guard
    end

    def guard
      self.id ||= SecureRandom.uuid
      self.parent_steps ||= []
      self.masher ||= Masher.new
      self.config ||= SymbolizedHash.new
    end

    def execute event
      guard

      mashed_config = masher.mash config, event

      results = process event, mashed_config

      returned_one_result = results.is_a?(Hash)

      results = [results]
        .flatten
        .map { |x| x.is_a?(Hash) ? convert_to_symbolized_hash(x) : nil }
        .select { |x| x }

      if config[:merge]
        keys_to_merge = config[:merge] == '*' ? event.keys.map { |x| x.to_s } : [config[:merge]]
        results = results.map do |result|
                    event.select { |k, _| keys_to_merge.include? k.to_s }.each do |k, v|
                      result[k] = v unless result[k]
                    end
                  end
      end

      results = results.map { |x| Masher.new.dig config[:split], x }.flatten if config[:split]

      results = results.map { |x| masher.mash config[:model], x } if config[:model]

      results = SymbolizedHash.new( { config[:join] => results } ) if config[:join]

      return results if config[:join]

      return results if config[:split]
      
      returned_one_result ? results.first : results
    end

    def convert_to_symbolized_hash event
      data = SymbolizedHash.new
      event.each { |k, v| data[k] = v }
      data
    end

    def process event, config
      event
    end

  end

end