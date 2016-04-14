require 'spec_helper'

describe JsonApiObjects::JsonApiObject do

  class LocationSalary
  end

  class Test
    def existing_method
      'abc'
    end

    def raw_job_id
      # This is included in the test jsons
      # The getter should not be overwritten
      1234
    end

    def raw_job_id=(_value)
      'set id'
    end

    def location_salaries
      [LocationSalary.new, LocationSalary.new]
    end
  end

  let(:raw_schema) { load_schema('test.json') }
  let(:raw_schema_2) { load_schema('test_2.json') }
  let(:schema_2) { schema_instance(raw: raw_schema_2) }

  describe '#initialize' do
    it 'raises no error' do
      expect { subject }.to_not raise_error
    end
  end

  describe '#extended_class' do
    it 'keeps existing class (Test)' do
      subject.send(:extended_class)
      expect(Test.instance_methods).to include(:existing_method)
    end

    it 'creates new class (Test2)' do
      subject(schema: schema_2).send(:extended_class)
      expect { Test2 }.to_not raise_error
    end

  end

  describe '#create_setter' do

    it 'adds setter to instance' do
      subject.send(:create_setter, 'property_string')
      expect(Test.instance_methods).to include(:property_string=)
    end
  end

  describe '#create_getter' do
    before(:each) do
      subject.send(:create_getter, 'property_string')
    end

    it 'adds getter to instance' do
      expect(Test.instance_methods).to include(:property_string)
    end
  end

  describe '#prepare' do
    before(:each) do
      subject.prepare
    end

    it 'creates getters'
    it 'creates setters'

    it 'does not overwrite existing getter' do
      expect(Test.new.raw_job_id).to eql 1234
    end

    # TODO: decide on whether to create setters
    xit 'does not overwrite existing setter' do
      expect(Test.new.raw_job_id = 'a').to eql 'set id'
    end

    it 'creates json_api_method' do
      expect(Test.instance_methods).to include(:json_api_object)
    end
    it 'prepares associated objects recursively'
  end

  describe '#create_api_object_method' do
    before(:each) do
      subject.prepare
    end

    it 'creates the json_api_object method' do
      expect(Test.instance_methods).to include(:json_api_object)
    end

    it 'returns hash with all attributes' do
      expect(Test.new.json_api_object).to eql ({ id: nil,
                                                  raw_job_id: 1234,
                                                  calculated_salary: nil,
                                                  location_salaries: [{amount: nil},{amount: nil}] }).to_json
    end
  end

  private

  def load_schema(filename)
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
