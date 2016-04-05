require 'spec_helper'

describe JsonApiObjects::JsonApiObject do

  class Test
    def existing_method
      "abc"
    end
  end

  let(:raw_schema){ load_schema("test.json") }
  let(:raw_schema_2){ load_schema("test_2.json") }
  let(:schema_2){ schema_instance(raw: raw_schema_2) }

  describe "#initialize" do 
    it "raises no error" do
      expect{ subject }.to_not raise_error
    end
  end

  describe "#extended_class" do

    it "keeps existing class (Test)" do
      subject.send(:extended_class)
      expect(Test.instance_methods).to include(:existing_method)
    end
 
    it "creates new class (Test2)" do
      subject(schema: schema_2).send(:extended_class)
      expect{ Test2 }.to_not raise_error 
    end
    
  end

  private

  def load_schema filename
    file = open([JsonApiObjects.root, 'spec/schemas', filename].join('/')) do |f|
      data = f.read
    end
    JSON.parse(file)
  end

  def schema_instance(raw: raw_schema)
    JsonApiObjects::Schema.init raw
  end
 
  def subject(schema: schema_instance)
    JsonApiObjects::JsonApiObject.new schema
  end

end
