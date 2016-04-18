require 'spec_helper'

describe JsonApiObjects do
  
  let(:schemas){ JsonApiObjects.fetch_schemas([JsonApiObjects::HOME,"spec/schemas"].join("/")) }
  let(:schema_instance){ JsonApiObjects::Schema.new(schemas[0]).init }
  
  it 'has a version number' do
    expect(JsonApiObjects::VERSION).not_to be nil
  end

  it "defines a root path" do
    expect(JsonApiObjects::HOME).to eql Pathname.new(File.join(File.dirname(__FILE__), '..')).realpath
  end

  it "inits schema" do
    expect{ schema_instance }.to_not raise_error
  end

  describe ".init" do

    after(:each) do
      JsonApiObjects.init(schemas)
    end

    xit "inits schema" do
      expect(JsonApiObjects::Schema).to receive(:init).with(instance_of(Hash)).and_return(test)
    end

    it "prepares api objects" 

  end

  describe ".process" do
    
    after(:each) do
      JsonApiObjects.process
    end

    context "no defined schemas" do

      it "calls init with empty array" do
        expect(JsonApiObjects).to receive(:init).with([])
      end

    end

  end

  describe ".fetch_schemas" do

    it "returns array of schemas" do
      expect( schemas ).to be_instance_of Array
      expect( schemas ).to_not be_empty
      schemas.each do |schema|
        expect( schema ).to be_instance_of Hash
        expect( schema ).to_not be_empty
      end
    end
  
  end


end
