module JsonApiObjects
  class Schema
    attr_accessor :raw_schema, :errors, :api_object_class, :description, :type, :properties, :required_attributes

    def self.init(raw_schema)
      new(raw_schema).init
    end

    def self.set_object_classes(schemas)
      @object_classes ||= {}
      schemas.map{ |schema| @object_classes[schema.description] = schema }
    end

    def self.object_class_names
      @object_classes.keys
    end

    def init
      set_attributes(symbolized_hash(raw_schema))
      self
    end

    private

    def initialize(raw_schema)
      @raw_schema = raw_schema
    end

    def set_attributes(description: '',
                       type:'',
                       properties:{},
                       required:[])
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
