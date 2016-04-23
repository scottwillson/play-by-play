module PlayByPlay
  module Model
    # make copies of immutable hash-like models
    module Duplication
      # duplicate self and merge attributes
      def merge(new_attributes = {})
        return self if new_attributes.nil? || new_attributes.empty?

        old_attributes = attributes
        merged_attributes = old_attributes

        new_attributes.each do |key, value|
          old_attribute = old_attributes[key]
          if value.respond_to?(:attributes)
            merged_attributes[key] = old_attribute.attributes.merge(value.attributes)
          elsif old_attribute.respond_to?(:merge)
            merged_attributes[key] = old_attribute.attributes.merge(value)
          else
            merged_attributes[key] = value
          end
        end

        self.class.new merged_attributes
      end

      def attributes
        hash = {}

        instance_variables.each do |iv|
          key = iv.to_s.tr("@", "").to_sym
          hash[key] = dup_value(key)
        end

        hash
      end

      def dup_value(key)
        value = send(key)
        case value
        when TrueClass, FalseClass, NilClass, Numeric, String, Symbol
          value
        else
          value.dup
        end
      end
    end
  end
end
