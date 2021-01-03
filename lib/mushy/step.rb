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

      shaping_methods = [:merge, :split, :model, :join]
      shaping = shaping_methods
                  .select { |x| config[x] }
                  .each_with_index
                  .sort_by { |x, i|
                    if config[:shaping] && config[:shaping].include?(x)
                      config[:shaping].index(x)
                    else
                      i
                    end }
                  .map { |x, _| x }
                  .reduce({}) { |t, i| t[i] = config[i]; t }

      shaping.each do |key, value|
        results = self.send("#{key}_these_results".to_sym, results, event, value)
      end

      return results.first if config[:join]

      return results if config[:split]
      
      returned_one_result ? results.first : results
    end

    def split_these_results results, event, by
      results.map { |x| Masher.new.dig by, x }.flatten
    end

    def join_these_results results, event, by
      [SymbolizedHash.new( { by => results } )]
    end

    def model_these_results results, event, by
      results.map { |x| masher.mash by, x }
    end

    def merge_these_results results, event, by
      keys_to_merge = if by == '*'
                        event.keys.map { |x| x.to_s }
                      else
                        [by].flatten.map { |x| x.split(',').map { |x| x.strip } }.flatten
                      end

      results.map do |result|
                    event.select { |k, _| keys_to_merge.include? k.to_s }.each do |k, v|
                      result[k] = v unless result[k]
                    end
                    result
                  end
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