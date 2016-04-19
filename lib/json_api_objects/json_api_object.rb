module JsonApiObjects
  class JsonApiObject
    attr_accessor :schema

    def self.prepare(schema)
      new(schema).prepare
    end

    def prepare
      schema.properties.each do |property, config|
        create_setter(property) unless extended_class.instance_methods.include?((property + '=').to_sym)
        create_getter(property) unless extended_class.instance_methods.include?(property.to_sym)
        create_api_object_method
        case config['type']
        when 'object'
          self.class.prepare(Schema.init(schema.properties[property])) if config['type'] == 'object' # TODO: Create Config object with object? method
        when 'array'
          self.class.prepare(Schema.init(config['items']))
        end
        create_validation_method
      end
    end

    private

    def initialize(schema)
      @schema = schema
    end

    def extended_class
      schema.description.split('::').inject(Object) do |mod, class_name|
        mod.const_get(class_name)
      end
    rescue NameError
      klass = Class.new
      Object.const_set schema.description, klass
      klass
    end

    def create_setter(property)
      extended_class.class_eval("def #{property}=(value);@#{property}=value;end")
    end

    def create_getter(property)
      extended_class.class_eval("def #{property};@#{property};end")
    end

    def create_api_object_method
      # TODO: Create config object
      extended_class.class_eval(
        <<EOF
      def json_api_object
        return_hash = {}
        #{schema.properties}.each do |property, config|
          return_hash[property] = case config["type"]
                                  when "object"
                                    self.send(property.to_sym).json_api_object
                                  when "array"
                                    return_array = self.send(property.to_sym) || []
                                    return_array.map{ |object| JSON.parse object.json_api_object }
                                  else
                                    self.send(property.to_sym)
                                  end
        end
        errors = validate_json_api_object(return_hash.to_json)
        if errors.empty?
          return_hash.to_json
        else
          # TODO: return errors
          return_hash.to_json
        end
      end
EOF
      )
    end

    def create_validation_method
      # TODO: validate and handle errors
      extended_class.class_eval(
        <<EOF
      def validate_json_api_object(json_api_object_hash)
        @_validation_schema = open(::JsonApiObjects.root + 'lib/json_api_objects/schemas/validation_schema') do |file|
                                data = file.read
                              end
        # s. https://github.com/ruby-json-schema/json-schema
        JSON::Validator.fully_validate(@_validation_schema, json_api_object_hash, errors_as_objects: true)
      end
EOF
      )
    end
  end
end
