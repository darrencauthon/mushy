module Mushy

  class Step

    attr_accessor :id
    attr_accessor :parent_steps
    attr_accessor :config

    def initialize
      guard
    end

    def guard
      self.id ||= SecureRandom.uuid
      self.parent_steps ||= []
      self.config ||= SymbolizedHash.new
    end

    def execute event
      guard

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