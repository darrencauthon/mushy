require 'json'

module Mushy

  class Flow
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
      type = record[:type] || record['type'] || record[:flux] || record['flux'] || 'Flux'
      flux = Object.const_get("Mushy::#{type}").new
      flux.id = record[:id] || record['id'] || flux.id
      flux.type = type
      flux.config = SymbolizedHash.new(record[:config] || record['config'])
      flux
    end

    def self.parse data
      data = JSON.parse data

      data_fluxs = data['fluxs'] || []
      data_fluxs.select { |x| x['parent'] }.map { |r| r["parents"] = [r["parent"]] }

      flow = new

      flow.fluxs = data_fluxs.map { |s| build_flux s }

      fluxs_with_parent_ids = flow.fluxs.reduce({}) { |t, i| t[i.id] = []; t }
      data_fluxs.map { |r| fluxs_with_parent_ids[r['id']] = r['parents'] || [] }

      flow.fluxs.each do |flux|
        flux.parent_fluxs = flow.fluxs.select { |x| fluxs_with_parent_ids[flux.id].include?(x.id) }
      end

      flow
    end

  end

end