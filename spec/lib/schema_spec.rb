require 'spec_helper'

describe JsonApiObjects::Schema do
  let!(:raw_schema) do
    file = open([JsonApiObjects.root, 'spec/schemas/test.json'].join('/')) do |f|
      data = f.read
    end
    JSON.parse(file)
  end

  context 'test' do
    it 'should be true' do
      expect(true).to be_truthy
    end
  end
end
