require 'json'

module Mushy

  class Workflow
    attr_accessor :id
    attr_accessor :fluxs

    def initialize
      self.id = SecureRandom.uuid
      self.fluxs = []
    end

    def fluxs_for event
      fluxs
        .select { |x| x.parent_fluxs.any? { |y| y.id == event.flux_id } }
        .flatten
    end

    def self.build_flux record
      flux = Object.const_get("Mushy::#{record[:type] || record['type'] || 'Flux'}").new
      flux.id = record[:id] || record['id'] || flux.id
      flux.config = SymbolizedHash.new(record[:config] || record['config'])
      flux
    end

    def self.parse data
      data = JSON.parse data
      workflow = new

      data_fluxs = data['fluxs'] || []

      workflow.fluxs = data_fluxs.map { |s| build_flux s }

      fluxs_with_parent_ids = workflow.fluxs.reduce({}) { |t, i| t[i.id] = []; t }
      data_fluxs.map { |r| fluxs_with_parent_ids[r['id']] = r['parent_fluxs'] || [] }

      workflow.fluxs.each do |flux|
        flux.parent_fluxs = workflow.fluxs.select { |x| fluxs_with_parent_ids[flux.id].include?(x.id) }
      end

      workflow
    end

  end

end