module JSONAPI
  module Realizer
    class Adapter
      MEMORY = Proc.new do
        find_many_via do |model_class|
          model_class.all
        end

        find_via do |model_class, id|
          model_class.fetch(id)
        end

        assign_attributes_via do |model, attributes|
          model.assign_attributes(attributes)
        end

        assign_relationships_via do |model, relationships|
          model.assign_attributes(relationships)
        end

        sparse_fields do |model_class, fields|
          model_class
        end

        include_via do |model_class, includes|
          model_class
        end

        create_via do |model|
          model.assign_attributes(id: model.id || SecureRandom.uuid)
          model.assign_attributes(updated_at: Time.now)
          model.class.const_get("STORE")[model.id] = model.class.const_get("ATTRIBUTES").inject({}) do |hash, key|
            hash.merge({ key => model.public_send(key) })
          end
        end

        update_via do |model|
          model.assign_attributes(updated_at: Time.now)
          model.class.const_get("STORE")[model.id] = model.class.const_get("ATTRIBUTES").inject({}) do |hash, key|
            hash.merge({ key => model.public_send(key) })
          end
        end
      end
    end
  end
end
