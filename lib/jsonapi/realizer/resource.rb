module JSONAPI
  module Realizer
    class Resource
      attr_reader :model

      def initialize(model)
        @model = model
      end

      private def as_relationship(value)
        data = value.fetch("data")
        mapping = JSONAPI::Realizer.mapping.fetch(data.fetch("type"))
        mapping.resource_class.find_via_call(
          mapping.model_class,
          data.fetch("id")
        )
      end

      private def attribute(name)
        attributes.public_send(name.to_sym)
      end

      private def relationship(name)
        relationships.public_send(name.to_sym)
      end

      private def attributes
        configuration.attributes
      end

      private def relationships
        configuration.relationships
      end

      private def model_class
        configuration.model_class
      end

      private def configuration
        self.class.configuration
      end

      def self.attribute(name)
        attributes.public_send(name.to_sym)
      end

      def self.relationship(name)
        relationships.public_send(name.to_sym)
      end

      def self.valid_attribute?(name, value)
        attributes.respond_to?(name.to_sym)
      end

      def self.valid_relationship?(name, value)
        relationships.respond_to?(name.to_sym)
      end

      def self.valid_sparse_field?(name)
        attribute(name).fetch(:selectable)
      end

      def self.valid_includes?(name)
        relationship(name).fetch(:includable)
      end

      def self.represents(type, class_name:)
        @configuration = JSONAPI::Realizer.register(self, class_name.constantize, type.to_s)
      end

      def self.adapter(interface, &block)
        JSONAPI::Realizer::Adapter.adapt(self, interface, &block)
      end

      def self.find_via(&callback)
        @find_via_call = callback
      end

      def self.find_via_call(model_class, id)
        @find_via_call.call(model_class, id)
      end

      def self.find_many_via(&callback)
        @find_many_via_call = callback
      end

      def self.find_many_via_call(model_class)
        @find_many_via_call.call(model_class)
      end

      def self.create_via(&callback)
        @create_via_call = callback
      end

      def self.create_via_call(model)
        @create_via_call.call(model)
      end

      def self.update_via(&callback)
        @update_via_call = callback
      end

      def self.update_via_call(model)
        @update_via_call.call(model)
      end

      def self.assign_attributes_via(&callback)
        @assign_attributes_via_call = callback
      end

      def self.assign_attributes_via_call(model, attributes)
        @assign_attributes_via_call.call(model, attributes)
      end

      def self.sparse_fields(&callback)
        @sparse_fields_call = callback
      end

      def self.sparse_fields_call(model_class, fields)
        @sparse_fields_call.call(model_class, fields)
      end

      def self.include_via(&callback)
        @include_via_call = callback
      end

      def self.include_via_call(model_class, include)
        @include_via_call.call(model_class, include)
      end

      def self.has(name, selectable: true)
        attributes.public_send("#{name}=", OpenStruct.new({name: name, selectable: selectable}))
      end

      def self.has_related(name, as: name, includable: true)
        relationships.public_send("#{name}=", OpenStruct.new({name: name, as: as, includable: includable}))
      end

      def self.has_one(name, as: name, includable: true)
        has_related(name, as: name, includable: includable)
      end

      def self.has_many(name, as: name, includable: true)
        has_related(name, as: name, includable: includable)
      end

      def self.attributes
        configuration.attributes
      end

      def self.relationships
        configuration.relationships
      end

      def self.model_class
        configuration.model_class
      end

      def self.configuration
        if @configuration
          @configuration
        else
          raise ArgumentError, "you need to have the resource configured"
        end
      end
    end
  end
end
