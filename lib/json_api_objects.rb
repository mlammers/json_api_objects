require 'json'
require 'json-schema'
require_relative 'json_api_objects/version'
require_relative 'json_api_objects/json_api_object'
require_relative 'json_api_objects/schema'

module JsonApiObjects

  HOME = Pathname.new(File.join(File.dirname(__FILE__), '..')).realpath

  if defined? ::Rails::Engine
    # auto wire assets as Rails Engine
    class Rails < ::Rails::Engine
    end

  elsif defined? ::Sprockets
    # Set up asset paths for Sprockets apps
    ::Sprockets.append_path File.join(root, "vendor", "assets", "javascripts")
  end

  def self.root
    HOME
  end

  def self.process(schema_path: File.join(root, "lib", "schemas"))
    schemas = fetch_schemas(schema_path)
    init schemas
  end

  def self.init(schemas)
    schemas.each do |schema|
      JsonApiObjects::JsonApiObject.prepare(JsonApiObjects::Schema.init(schema))
    end
  end

  private
  
  def self.fetch_schemas(folder)
    dir = Dir.glob("#{folder}/*.json")
    schemas = []
    errors = {}
    dir.each do |filename|
      file = open(filename) do |f|
        data = f.read
      end
      schemas << JSON.parse(file)
    end
    schemas
  end

end
