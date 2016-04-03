require 'json'
require 'json-schema'
require_relative 'json_api_objects/version'
require_relative 'json_api_objects/json_api_object'
require_relative 'json_api_objects/schema'

module JsonApiObjects
  HOME = Pathname.new(File.join(File.dirname(__FILE__), '..')).realpath

  def self.root
    HOME
  end

  # TODO: change folders to use root
  def self.process(schema_folder: 'json_api_objects/schemas')
    # validation_schema: 'json_api_objects/validation_schema')
    # get schema_files from schema folder
    dir = Dir.glob("#{schema_folder}/*.json")
    schemas = []
    errors = {}
    dir.each do |filename|
      file = open(filename) do |f|
        data = f.read
      end
      schemas << JSON.parse(file)
      # schemas << JSON.parse(file. object_class: JsonApiObjects::Schema)
    end
    init schemas
  end

  def self.init(schemas)
    schemas.each do |schema|
      JsonApiObjects::JsonApiObject.prepare(JsonApiObjects::Schema.init(schema))
    end
  end
end
JsonApiObjects.process
