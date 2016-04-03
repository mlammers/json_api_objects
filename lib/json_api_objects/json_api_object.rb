module JsonApiObjects
  class JsonApiObject
    attr_accessor :schema

    def self.prepare(schema)
      new(schema).prepare
    end

    def prepare
      schema.properties.each do |property, config|
        create_setter(property) unless extended_class.methods.include?(property)
        create_getter(property) unless extended_class.methods.include?(property + '=')
        create_api_object_method
        self.class.prepare(Schema.init(config)) if config['type'] == 'object' # TODO: Create Config object with object? method
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
end