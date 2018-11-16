require 'rails_helper'

RSpec.describe EmployeeComment, type: :model do
  it { should validate_presence_of(:text)}
  it { should validate_presence_of(:comment_type)}

  it { should belong_to(:user)}
  it "should be deleted when delete user" do
    user = create(:user)
    comment = create(:employee_comment, user_id: user.id)

    expect { user.destroy }.to change { EmployeeComment.count }.by(-1)
  end
end
