module JsonApiObjects
  class Schema
    attr_accessor :raw_schema, :errors, :api_object_class, :title, :type, :properties, :required_attributes

    def self.init(raw_schema)
      new(raw_schema).init
    end

    def init
      validate
      process_errors unless errors.empty?
      set_attributes(symbolized_hash(raw_schema))
      self
    end

    private

    def initialize(raw_schema)
      @raw_schema = raw_schema
    end

    def validate
      @errors = []
      # TODO: Fix validation
      #JSON::Validator.fully_validate(JsonApiObjects.root + 'lib/json_api_objects/validation_schema.rb', raw_schema)
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
        new_hash[key.to_sym] = hash[key] unless key == '$schema'
      end
      new_hash
    end
  end
end
