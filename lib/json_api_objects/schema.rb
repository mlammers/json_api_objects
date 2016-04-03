module JsonApiObjects
  class Schema
    attr_accessor :raw_schema, :errors, :api_object_class, :title, :type, :properties, :required_attributes

    def self.init(raw_schema)
      new(raw_schema).init
    end

    def init
      validate
      process_errors unless errors.empty?
      raw_schema.delete('$schema')
      set_attributes(symbolized_hash(raw_schema))
      self
    end

    private

    def initialize(raw_schema)
      @raw_schema = raw_schema
    end

    def validate
      @errors = JSON::Validator.fully_validate('json_api_objects/validation_schema', raw_schema)
    end

    def set_attributes(title:nil,
                       description: nil,
                       type:nil,
                       properties:nil,
                       required:nil)
      @title = title
      @description = description
      @type = type
      @properties = properties
      @required_attributes = required
    end

    def symbolized_hash(hash)
      new_hash = {}
      hash.each_key do |key|
        new_hash[key.to_sym] = hash[key]
      end
      new_hash
    end
  end
end
