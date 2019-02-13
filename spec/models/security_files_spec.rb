require 'rails_helper'

RSpec.describe SecurityFile, type: :model do
  it { should validate_presence_of(:base64) }
end
