require 'rails_helper'

RSpec.describe Ethnicity, type: :model do
  describe 'validations' do
    it 'requires the presence of name' do
      ethnicity = Ethnicity.new(name: '')
      expect(ethnicity).to_not be_valid
    end
  end

  describe '#to_label' do
    it 'returns a string interpolation of the ethnicity name and description' do
      ethnicity = create(:ethnicity, :white)
      expect(ethnicity.to_label).to eq("#{ethnicity.name}: #{ethnicity.description}")
    end
  end
end
