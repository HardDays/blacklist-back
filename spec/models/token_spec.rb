require 'rails_helper'

RSpec.describe Token, type: :model do
  it { should validate_presence_of(:info) }
  it { should belong_to(:user) }
end
