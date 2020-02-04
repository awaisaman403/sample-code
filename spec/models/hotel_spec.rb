require 'rails_helper'

RSpec.describe Hotel, type: :model do
  describe 'Associations' do
    it { should have_many(:users) }
  end

  describe 'Validations' do
    it { should validate_presence_of(:external_id) }
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:phone) }

    it { should validate_uniqueness_of(:external_id).case_insensitive }
    it { should validate_uniqueness_of(:phone).case_insensitive }
  end

  it 'has a valid factory' do
    expect(FactoryGirl.build(:hotel)).to be_valid
  end
end
