require 'spec_helper'

describe JsonApiObjects::Schema do
  let!(:raw_schema) do
    file = open([JsonApiObjects.root, 'spec/schemas/test.json'].join('/')) do |f|
      data = f.read
    end
    JSON.parse(file)
  end

  let(:subject) do
    JsonApiObjects::Schema.new(raw_schema)
  end


  describe ".init" do
    it "does not raise errors" do
      expect{ JsonApiObjects::Schema.init(raw_schema) }.to_not raise_error
    end
  end

  describe "#validate"

  describe "#set_attributes" do
    it "sets attributes correctly" do
      subject.send(:set_attributes, symbolize_hash)
      expect(subject.title).to eql symbolize_hash[:title]
      expect(subject.type).to eql symbolize_hash[:type]
      expect(subject.properties).to eql symbolize_hash[:properties]
      expect(subject.required_attributes).to eql symbolize_hash[:required]
    end
  end

  describe "#symbolized_hash" do
    it "returns hash with symbolized keys" do
      expect(subject.send(:symbolized_hash, {"a" => "a", "b" => "b"})).to eql({:a => "a", :b => "b"})
    end

    it "cuts $schema key" do
      expect(subject.send(:symbolized_hash, {"a" => "a", "$schema" => "test"})).to eql({:a => "a"})
    end
  end

  private

  def symbolize_hash
    subject.send(:symbolized_hash, raw_schema)
  end
end
