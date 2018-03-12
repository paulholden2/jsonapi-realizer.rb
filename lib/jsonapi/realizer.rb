require "ostruct"
require "active_support/concern"
require "active_support/core_ext/enumerable"

module JSONAPI
  module Realizer
    require_relative "realizer/version"
    require_relative "realizer/action"
    require_relative "realizer/adapter"
    require_relative "realizer/resource"

    def self.register(resource_class:, model_class:, adapter:, type:)
      @mapping ||= Set.new
      @mapping << OpenStruct.new({
        resource_class: resource_class,
        model_class: model_class,
        adapter: adapter,
        type: type,
        attributes: OpenStruct.new({}),
        relationships: OpenStruct.new({})
       })
    end

    def self.resource_mapping
      @mapping.index_by(&:resource_class)
    end

    def self.type_mapping
      @mapping.index_by(&:type)
    end

    def self.create(payload, headers:)
      Create.new(payload: payload, headers: headers).tap(&:call)
    end

    def self.update(payload, headers:)
      Update.new(payload: payload, headers: headers).tap(&:call)
    end

    def self.show(payload, headers:, type:)
      Show.new(payload: payload, headers: headers, type: type).tap(&:call)
    end

    def self.index(payload, headers:, type:)
      Index.new(payload: payload, headers: headers, type: type).tap(&:call)
    end
  end
end
