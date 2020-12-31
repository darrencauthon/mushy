module Mushy

  class Step

    attr_accessor :id
    attr_accessor :parent_steps
    attr_accessor :config_to_mash
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
      self.config_to_mash ||= SymbolizedHash.new

      self.config.each do |key, value|
        if config_to_mash[key].nil?
          config_to_mash[key] = value
        end
      end

      self.config
        .select { |k, _| config_to_mash[k].nil? }
        .each   { |k, v| config_to_mash[k] = v }

      self.config_to_mash.each { |k, v| config[k] = v }
    end

    def execute event
      guard

      self.config = masher.mash config, event

      results = process(event)

      returned_one_result = results.is_a?(Hash)

      results = [results]
        .flatten
        .map { |x| x.is_a?(Hash) ? convert_to_symbolized_hash(x) : nil }
        .select { |x| x }

      results = results.map { |x| masher.mash config[:model], x } if config[:model]
      
      returned_one_result ? results.first : results
    end

    def convert_to_symbolized_hash event
      data = SymbolizedHash.new
      event.each { |k, v| data[k] = v }
      data
    end

    def process event
      puts id
      nil
    end

  end

  class ThroughStep < Step
    def process event
      puts "id: #{id}"
      puts event.inspect
      event
    end
  end

end