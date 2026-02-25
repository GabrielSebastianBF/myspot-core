class Tool < ApplicationRecord
  validates :name, presence: true, uniqueness: true

  def can_execute?(role)
    allowed_roles.include?(role)
  end
end
