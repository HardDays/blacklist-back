require 'rails_helper'

RSpec.describe News, type: :model do
  it { should validate_presence_of(:text) }
end
