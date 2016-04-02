require 'json'
require 'json-schema'

class Test
end


module JsonApiObjects

  class JsonApiObject

    attr_accessor :schema
     
    def self.prepare(schema)
      new(schema).prepare
    end

    def prepare
      p extended_class
      # p method(__method__).parameters

      # set api object class (ApiObject.init(title, properties))
      # 1. find class or create one
      # @api_object_class = (title.classify rescue Class.new(title))
      # p type
      # 2. set properties, create attributes, setters and getters for each property
      # properties.each do |prop_name, prop_values|
        # if prop_values["type"]=="object"
        #   recursive call to init  class
      #   @api_object_class.class_eval(:attr_accessor, :prop)
      # end
    end

    private
  
    def initialize(schema)
      @schema = schema
    end

    def extended_class
      schema.title.split('::').inject(Object) do |mod, class_name|
        mod.const_get(class_name)
      end
    rescue => e
      klass = Class.new
      Object.const_set schema.title, klass
      klass
    end

  end

  class Schema

=begin
    def initialize(title: nil,
                   description: nil,
                   type: nil,
                   properties: nil,
                   required: nil)
      p self



    def class << self
      attr_accessor :schema
    end
=end
    attr_accessor :raw_schema, :errors, :api_object_class, :title, :type, :properties, :required_attributes

    def self.init(raw_schema)
      new(raw_schema).init
    end

    def init
      validate
      process_errors unless errors.empty?
      raw_schema.delete("$schema")
      set_attributes(symbolized_hash(raw_schema))
      self
    end

    private

    def initialize(raw_schema)
      @raw_schema = raw_schema
    end

    def validate
      @errors = JSON::Validator.fully_validate('validation_schema', raw_schema)
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
      new_hash = Hash.new
      hash.each_key do |key|
        new_hash[key.to_sym] = hash[key]
      end
      new_hash
    end 
 
  end

  def self.process(schema_folder: 'schemas',
                  validation_schema: 'validation_schema')
    # get schema_files from schema folder
    dir = Dir.glob("#{schema_folder}/*.json")
    schemas = [] 
    errors = {}
    dir.each do |filename| 
      #
      # for each filename in the folder
      file = open(filename){ |f|
        data = f.read
      }
      errors[filename.gsub('.json','')]=JSON::Validator.fully_validate(validation_schema, file)
      # raise errors if there are any
      schemas << JSON.parse(file)
    end
    init schemas
  end

  def self.init(schemas)
    schemas.each do |schema|
      JsonApiObject.prepare(Schema.init(schema))
    end 
  end

end
JsonApiObjects.process
