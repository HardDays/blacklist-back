require 'rails_helper'

RSpec.describe BanList, type: :model do
  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:description) }
end
