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

      results = results.map { |x| masher.mash config[:model], x } if config[:model]

      if config[:split]
        results = results.map { |x| Masher.new.dig config[:split], x }.flatten
        return results
      end
      
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