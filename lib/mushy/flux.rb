module Mushy

  class Flux

    attr_accessor :id
    attr_accessor :type
    attr_accessor :parent_fluxs
    attr_accessor :subscribed_to
    attr_accessor :config
    attr_accessor :masher

    def initialize
      guard
    end

    class << self
      attr_accessor :all

      def inherited subclass
        if (self != Mushy::Flux)
          Mushy::Flux.inherited subclass
        else
          self.all ||= []
          self.all << subclass
        end
      end
    end

    def guard
      self.id ||= SecureRandom.uuid
      self.parent_fluxs ||= []
      self.subscribed_to ||= []
      self.masher ||= Masher.new
      self.config ||= SymbolizedHash.new
    end

    def execute incoming_event
      guard

      incoming_event = SymbolizedHash.new(incoming_event) if incoming_event.is_a?(Hash)

      event = incoming_event

      incoming_split = masher.mash(config, event)[:incoming_split]
      config_considering_an_imcoming_split = config
                                               .reject { |x, _| incoming_split && x.to_s == 'join' }
                                               .reduce({}) { |t, i| t[i[0]] = i[1]; t }

      events = incoming_split ? incoming_event[incoming_split] : [event]

      results = events.map { |e| execute_single_event e, config_considering_an_imcoming_split }

      return results.first unless incoming_split

      results = join_these_results([results].flatten, event, config[:join]) if config[:join]

      results.flatten
    end

    def execute_single_event event, config

      mashed_config = masher.mash config, event

      the_original_join = mashed_config[:join]
      mashed_config[:join] = nil if mashed_config[:incoming_split]

      results = process event, mashed_config

      returned_one_result = results.is_a?(Hash)

      results = standardize_these results
      results = shape_these results, event, config

      return results.first if the_original_join

      return results if mashed_config[:outgoing_split]
      
      returned_one_result ? results.first : results

    end

    def standardize_these results
      [results]
        .flatten
        .map { |x| x.is_a?(Hash) ? convert_to_symbolized_hash(x) : nil }
        .select { |x| x }
    end

    def shape_these results, event, config
      supported_shaping = [:merge, :outgoing_split, :group, :model, :join, :sort, :limit]

      shaping = supported_shaping
      if (config[:shaping])
        shaping = convert_this_to_an_array(config[:shaping]).map { |x| x.to_sym }
      end

      supported_shaping
        .select { |x| config[x] }
        .each_with_index
        .sort_by { |x, i| shaping.index(x) || i + supported_shaping.count }
        .map { |x, _| x }
        .reduce(results) { |t, i| self.send("#{i}_these_results".to_sym, t, event, config[i]) }
    end

    def sort_these_results results, event, by
      results.sort { |x| x[by].to_i }
    end

    def limit_these_results results, event, by
      results
        .each_with_index
        .select { |x, i| i < by.to_i }
        .map { |x, _| x }
    end

    def group_these_results results, event, by
      group_by = by.split('|')[0]
      result_key = by.split('|')[1]
      results.group_by { |x| x[group_by] }.map { |k, v| SymbolizedHash.new( { result_key => v } ) }
    end

    def outgoing_split_these_results results, event, by
      results.map { |x| Masher.new.dig by, x }.flatten
    end

    def join_these_results results, event, by
      [SymbolizedHash.new( { by => results } )]
    end

    def model_these_results results, event, by
      return results unless by.any?
      results.map { |x| masher.mash by, x }
    end

    def merge_these_results results, event, by
      keys_to_merge = convert_this_to_an_array by
      keys_to_merge = event.keys.map { |x| x.to_s } if (keys_to_merge[0] == '*')

      results.map do |result|
                    event.select { |k, _| keys_to_merge.include? k.to_s }.each do |k, v|
                      result[k] = v unless result[k]
                    end
                    result
                  end
    end

    def convert_this_to_an_array value
      [value]
        .flatten
        .map { |x| x.to_s.split(',').map { |x| x.strip } }
        .flatten
        .select { |x| x && x != '' }
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