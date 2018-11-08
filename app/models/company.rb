class Company < ApplicationRecord
  validates_presence_of :name

  belongs_to :user
  has_many :vacancies, dependent: :destroy

  def as_json(options={})
    res = super
    res.delete("user_id")
    res[:id] = user_id

    if options[:only]
      return res
    end


    res
  end
end
