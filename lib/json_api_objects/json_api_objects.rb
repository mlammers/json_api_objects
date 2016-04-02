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
      schema.properties.each do |property, config|
        create_setter(property) unless extended_class.methods.include?(property)
        create_getter(property) unless extended_class.methods.include?(property + "=")
        create_api_object_method
        if config["type"] == "object" #TODO: Create Config object with object? method
          self.class.prepare(Schema.init(config))
        end
      end
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

    def create_setter(property)
      extended_class.class_eval("def #{property}=(value);@#{property}=value;end")
    end
  
    def create_getter(property)
      extended_class.class_eval("def #{property};@#{property};end")
    end

    def create_api_object_method
      # verify required attributes
      # add all properties
      # TODO: Create config object
      # TODO: set object return to actually return the resp. object
      extended_class.class_eval(
<<EOF
      def json_api_object
        return_hash = {}
        #{schema.properties}.each do |property, config|
          return_hash[property] = case config["type"] 
                                  when "object"
                                    self.send(property.to_sym).json_api_object
                                  else
                                    self.send(property.to_sym)
                                  end
        end
        return_hash.to_json
      end
EOF
)
    end

  end

  class Schema

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
