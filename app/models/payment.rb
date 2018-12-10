class Payment < ApplicationRecord
  validates_uniqueness_of :subscription_id, scope: :status

  belongs_to :subscription

  enum status: [:added, :ok]

  def self.get_hash(*s)
    Digest::SHA256.hexdigest(s.join(':'))
  end
end
